class Shout
  include Mongoid::Document
  include Mongoid::Timestamps
  field :content, :type => String
  belongs_to_related :user
  belongs_to_related :project

  validates_presence_of :user_id, :project_id, :content
end
