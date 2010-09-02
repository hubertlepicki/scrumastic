# encoding: UTF-8

require 'carrierwave/orm/mongoid'

# It is what it's all about :).
class Project
  include Mongoid::Document
  include Mongoid::Timestamps
  include ArrayAttributes

  field :name, :type => String
  field :description, :type => String
  array_attributes :team_member_ids, :stakeholder_ids

  belongs_to_related :scrum_master, :class_name => "User"
  belongs_to_related :product_owner, :class_name => "User"
  belongs_to_related :owner, :class_name => "User"
  has_many_related :sprints
  has_many_related :user_stories

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
    ([self.scrum_master_id] + self.team_member_ids).select {|u_id| !u_id.blank?}
  end

  # True if user is allowed to remove given project
  def can_destroy?(someone)
    can_edit? someone
  end

  # True if user is allowed to edit given project
  def can_edit?(someone)
    owner_id == someone.id
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
    assignable_people_ids.include?(someone.id) ||
    (product_owner_id == someone.id)
  end

  # True if user is allowed to see project dashboard and user stories
  def can_see?(someone)
    can_edit?(someone) ||
    involved_people_ids.include?(someone.id)
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
      [self.scrum_master_id, self.product_owner_id] + self.team_member_ids + self.stakeholder_ids
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

  private

  # Validates that one user must play only one role in Project.
  # makes project.valid? return false, prevents it from saving
  # and sets project.errors hash with proper message
  def uniqueness_of_roles
    ids = involved_people_ids
    doubled_ids = ids.select {|user_id| ids.index(user_id) != ids.rindex(user_id) }
    if doubled_ids.include?(scrum_master_id)
      errors[:scrum_master_id] << "must have unique role"
    end
    if doubled_ids.include?(self.product_owner_id)
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
