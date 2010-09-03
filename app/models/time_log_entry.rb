class TimeLogEntry
  include Mongoid::Document
  include Mongoid::Timestamps
  references_one :sprint
  references_one :project
  references_one :user
  references_one :user_story

  validates_presence_of :sprint, :project, :user
end
