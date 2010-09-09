# encoding: utf-8

# Model that is representing user, using Devise plugin for providing
# authentication, remember me, confirm account, recover password and
# register logic
class User
  include Mongoid::Document
  include Mongoid::Timestamps
  include Gravtastic
  field :name, :type => String
  field :nickname, :type => String
  
  devise :database_authenticatable, :rememberable, :confirmable, :recoverable, :registerable
  validates_presence_of :nickname, :name, :email
  validates_confirmation_of :password
  validates_presence_of :password, :only => [:create]
  validates_uniqueness_of :nickname
  validates_format_of :nickname, :with => /^([a-z])*$/
  
  is_gravtastic # we want to have avatar of user with gravatar.com service

  has_many_related :projects, foreign_key: :owner_id # projects created and administrated by user
  references_many :time_log_entries, :dependent => :nullify

  # Removes user and his involvement in all projects
  def destroy
    Project.all(conditions: {product_owner_id: id}).each do |project|
      project.update_attributes(product_owner_id: nil)
    end
    Project.all(conditions: {scrum_master_id: id}).each do |project|
      project.update_attributes(scrum_master_id: nil)
    end
    Project.any_in(team_member_ids: [id.to_s]).each do |project|
      project.update_attributes(team_member_ids: project.team_member_ids.select{|tm_id| tm_id != id.to_s})
    end
    Project.any_in(stakeholder_ids: [id.to_s]).each do |project|
      project.update_attributes(stakeholder_ids: project.stakeholder_ids.select{|st_id| st_id != id.to_s})
    end
    super
  end

  # Returns link to 64x64 user avatar using gravatar.com service
  def big_gravatar_url
    gravatar_url + "&size=64"
  end


  # Returns link to 24x24 user avatar using gravatar.com service
  def medium_gravatar_url
    gravatar_url + "&size=24"
  end

  # Helper method, use to determine role of user in project.
  # Returns :scrum_master, :product_owner, :team_member, :stakeholder if
  # user plays any of those roles in project or nil if is not involved
  def role_in_project(project)
    if project.scrum_master == self
      return :scrum_master
    elsif project.product_owner == self
      return :product_owner
    elsif project.team_member_ids.include?(self.id.to_s)
      return :team_member
    elsif
      project.stakeholder_ids.include?(self.id.to_s)
      return :stakeholder
    end
    nil
  end

  # Returns link to 16x16 user avatar using gravatar.com service
  def small_gravatar_url
    gravatar_url + "&size=16"
  end

  def current_time_log_entry(project)
    time_log_entries.find(:first, :conditions => {current: true, project_id: project.id})
  end
end
