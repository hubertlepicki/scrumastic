# encoding: UTF-8

class AttachmentsController < ProjectScopedController
  respond_to :html, :json

  def show
    attachment = Attachment.find(params[:id])
    Can.edit?(current_user, attachment) do
      send_file attachment.file.file.file
    end
  end
end
