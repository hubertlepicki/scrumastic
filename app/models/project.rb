# encoding: UTF-8

require 'carrierwave/orm/mongoid'

# It is what it's all about :).
class Project
  include Mongoid::Document
  include Mongoid::Timestamps
  include ArrayAttributes

  field :name, :type => String
  field :description, :type => String
  field :repository_url, :type => String
  field :size_at, :type => Hash, :default => {}
  field :test_to_code_ratio_at, :type => Hash, :default => {}
  field :complexity_at, :type => Hash, :default => {}

  array_attributes :team_member_ids, :stakeholder_ids

  belongs_to_related :scrum_master, :class_name => "User"
  belongs_to_related :product_owner, :class_name => "User"
  belongs_to_related :owner, :class_name => "User"
  has_many_related :sprints, :dependent => :destroy
  has_many_related :user_stories, :dependent => :destroy
  has_many_related :shouts, :dependent => :destroy
  references_many :attachments, :dependent => :destroy
  references_many :time_log_entries, :dependent => :destroy
  mount_uploader :logo, ProjectLogoUploader

  validates_presence_of :name
  validates_uniqueness_of :name, :scope => :owner_id
  validates_format_of :repository_url, with: URI::regexp(["http", "https", "git"]), if: Proc.new {|o| !o.repository_url.blank? }
  validate :uniqueness_of_roles

  # People that you can assign user stories to.
  def assignable_people
    assignable_people_ids.collect{|user_id| User.find(user_id)}
  end

  # Ids of people that you can assign user stories to.
  def assignable_people_ids
    ([self.scrum_master_id.to_s] + self.team_member_ids).select {|u_id| !u_id.blank?}
  end

  # True if user is allowed to remove given project
  def can_destroy?(someone)
    can_edit? someone
  end

  # True if user is allowed to edit given project
  def can_edit?(someone)
    owner_id.to_s == someone.id.to_s
  end

  # True if user can edit sprint details for this project
  def can_edit_sprints_for?(someone)
    can_edit?(someone) || 
    (scrum_master_id == someone.id) ||
    (product_owner_id == someone.id)
  end

  # True if user is allowed to edit user stories in project
  def can_edit_user_stories_for?(someone)
    can_edit?(someone) ||
    assignable_people_ids.include?(someone.id.to_s) ||
    (product_owner_id.to_s == someone.id.to_s)
  end

  # True if user is allowed to see project dashboard and user stories
  def can_see?(someone)
    can_edit?(someone) ||
    involved_people_ids.include?(someone.id.to_s)
  end

  # Removes project and associated sprints and user stories
  def destroy
    sprints.each {|sprint| sprint.destroy(true) }
    UserStory.destroy_all(:conditions => {:project_id => id})
    super
  end

  # People that are assigned to this project, including all roles
  def involved_people
    involved_people_ids.collect{|user_id| User.find(user_id)}
  end

  # Ids of people assigned to this project
  def involved_people_ids
    (
      [self.scrum_master_id.to_s, self.product_owner_id.to_s] + self.team_member_ids + self.stakeholder_ids
    ).select {|u_id| !u_id.blank?}
  end

  # People that play a "chicken" role in project - observers
  def stakeholders
    self.stakeholder_ids.collect{|user_id| User.find(user_id)}
  end

  # People being team members
  def team_members
    self.team_member_ids.collect{|user_id| User.find(user_id)}
  end

  def current_time_log_entries
    TimeLogEntry.all(conditions: {current: true, project_id: id})  
  end

  def worked_time(from=created_at, to=Time.zone.now)
    from = created_at if from.blank?
    to = created_at if to.blank?
    TimeLogEntry.all(conditions: 
                       {project_id: id, :created_at.gte => from, :created_at.lte => to}
                    ).collect{|e| e.number_of_seconds}.sum
  end

  def prepare_reporting
     return if sprints.count == 0
    `mkdir -p tmp/repositories`
     
     repo = SCM::GitAdapter.clone_repository(repository_url, "#{Rails.root}/tmp/repositories/#{id}")

     from = start_date
     to = end_date
    
     self.size_at = {} if size_at.nil?
     self.test_to_code_ratio_at = {} if test_to_code_ratio_at.nil?
     self.complexity_at = {} if complexity_at.nil?


     (from..to).each do |day|
       if size_at[day.to_s].nil? || test_to_code_ratio_at[day.to_s].nil? || complexity_at[day.to_s].nil?
         `cd #{Rails.root}/tmp/repositories/#{id} && git checkout master`
         added_lines = repo.added_lines_count(from.midnight, day.end_of_day, /^(app|lib)/)
         removed_lines = repo.removed_lines_count(from.midnight, day.end_of_day, /^(app|lib)/)
         next unless added_lines && removed_lines

         all_lines = added_lines - removed_lines
         self.size_at[day.to_s] = all_lines

         test_added_lines = repo.added_lines_count(from.midnight, day.end_of_day, /^spec/)
         test_removed_lines = repo.removed_lines_count(from.midnight, day.end_of_day, /^spec/)
         test_lines = test_added_lines - test_removed_lines

         next unless test_added_lines && test_removed_lines
         self.test_to_code_ratio_at[day.to_s] = round(test_lines.to_f / all_lines.to_f, 2)
         command = "cd #{Rails.root}/tmp/repositories/#{id} && git checkout master && git checkout `git rev-list -n 1 --before=\"#{day.end_of_day}\" master`; "
         `#{command}`
         command = "cd #{Rails.root}/tmp/repositories/#{id}/app && metric_abc `find . -iname *.rb`"
         output = `#{command}`
         lines = output.split("\n")
         self.complexity_at[day.to_s] = round((lines.collect{|l| Math.exp(l.split(": ").last.to_f/10.0) }.sum) / all_lines.to_f, 2)
       end
     end 

     save
  end

  def velocity_at
    
  end

  def start_date
    sprints.collect {|s| s.start_date.to_date}.min
  end

  def end_date
    sprints.collect {|s| s.end_date.to_date}.max
  end

  private
  def round(float, num_of_decimal_places)
    exponent = num_of_decimal_places + 2
    @float = float*(10**exponent)
    @float = @float.round
    @float = @float / (10.0**exponent)
  end 

  # Validates that one user must play only one role in Project.
  # makes project.valid? return false, prevents it from saving
  # and sets project.errors hash with proper message
  def uniqueness_of_roles
    ids = involved_people_ids
    doubled_ids = ids.select {|user_id| ids.index(user_id) != ids.rindex(user_id) }
    if doubled_ids.include?(scrum_master_id.to_s)
      errors[:scrum_master_id] << "must have unique role"
    end
    if doubled_ids.include?(self.product_owner_id.to_s)
      errors[:product_owner_id] << "must have unique role"
    end
    if self.team_member_ids - doubled_ids != self.team_member_ids
      errors[:team_member_ids] << "must have unique role"
    end
    if self.stakeholder_ids - doubled_ids != self.stakeholder_ids
      errors[:stakeholder_ids] << "must have unique role"
    end
  end

end
