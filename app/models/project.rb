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
  field :application_regexp, :type => String
  field :tests_regexp, :type => String
  array_attributes :team_member_ids, :stakeholder_ids

  belongs_to_related :scrum_master, :class_name => "User"
  belongs_to_related :product_owner, :class_name => "User"
  belongs_to_related :owner, :class_name => "User"
  has_many_related :sprints, :dependent => :destroy
  has_many_related :user_stories, :dependent => :destroy
  has_many_related :shouts, :dependent => :destroy
  references_many :attachments, :dependent => :destroy
  references_many :time_log_entries, :dependent => :destroy
  references_many :remaining_points_metrics, class_name: "Metrics::RemainingPoints", dependent: :destroy
  references_many :velocity_metrics, class_name: "Metrics::Velocity", dependent: :destroy
  mount_uploader :logo, ProjectLogoUploader

  validates_presence_of :name
  validates_uniqueness_of :name, :scope => :owner_id
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

  def worked_time(from=created_at, to=Time.zone.now, user_id=nil)
    from = created_at if from.blank?
    to = created_at if to.blank?
    query = {project_id: id, :created_at.gte => from, :created_at.lte => to}
    query.merge!({user_id: user_id}) unless user_id.blank?
    TimeLogEntry.all(conditions: query).collect{|e| e.number_of_seconds}.sum
  end

  def start_date
    sprints.collect {|s| s.start_date.to_date}.min
  end

  def end_date
    sprints.collect {|s| s.end_date.to_date}.max
  end
  
  private

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
