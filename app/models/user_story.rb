# encoding: UTF-8

# User story, a type of 'ticket' with strict format checking.
class UserStory
  include Mongoid::Document
  include Mongoid::Timestamps
  field :who, type: String
  field :what, type: String
  field :reason, type: String
  field :description, type: String
  field :bug, type: Boolean
  field :in_backlog, type: Boolean
  field :position, type: Integer
  field :state, type: String
  field :story_points, type: Integer

  belongs_to_related :project
  belongs_to_related :sprint
  belongs_to_related :user
  has_many_related :comments
  validates_presence_of :who, :what, :project_id

  # Story point values that you can select when estimating
  # complexity of user story
  STORY_POINTS_SCALE = [ 0, 1, 2, 4, 8, 16, 32, 64 ]

  def initialize(args={})
    super(args)
    self.in_backlog ||= false
    self.bug ||= false
    self.position ||= 0
    self.state ||= "open"
    self.story_points ||= 0
  end

  # Moves user story to product backlog from incubator or
  # sprint backlog
  def move_to_backlog!
    update_attributes in_backlog: true, sprint_id: nil
  end

  # Moves given story back to incubator, either form sprint
  # backlog or product backlog
  def move_to_incubator!
    update_attributes in_backlog: false, sprint_id: nil
  end

  # Assigns user story to given sprint
  def move_to_sprint!(given_sprint)
    update_attributes sprint_id: given_sprint.id, in_backlog: true
  end
end
