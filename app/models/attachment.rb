class Attachment
  include Mongoid::Document
  include Mongoid::Timestamps
  field :description, :type => String
  mount_uploader :file, AttachmentUploader

  referenced_in :project
  referenced_in :comment
  validates_presence_of :project_id, :file

  def can_edit?(someone)
    project.involved_people_ids.include?(someone.id.to_s)
  end
end
