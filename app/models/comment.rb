# encoding: UTF-8

require 'carrierwave/orm/mongoid'

# Provides simple discussion and file upload mechanism for user stories.
class Comment
  include Mongoid::Document
  include Mongoid::Timestamps
  field :content, :type => String

  belongs_to_related :user
  belongs_to_related :user_story

  references_one :attachment

  # True if user is allowed to edit this comment
  def can_edit?(someone)
    (someone.id == user.id) || (user_story.project.owner.id == someone.id)
  end
end
