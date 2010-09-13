class Attachment
  include Mongoid::Document
  include Mongoid::Timestamps

  mount_uploader :file, AttachmentUploader

  referenced_in :project
  validates_presence_of :project_id

  def can_edit?(someone)
    project.involved_people_ids.include?(someone.id.to_s)
  end
end
