# encoding: UTF-8

class AttachmentsController < ProjectScopedController
  respond_to :html, :json

  def new
    @attachment = Attachment.new
  end

  def create
    @attachment = Attachment.new(params[:attachment])
    @attachment.project = @project
    if @attachment.save
      redirect_to [:project, :attachments]
    else
      render action: "new"
    end
  end

  def index
    @attachments = Attachment.find(:all, conditions: {project_id: @project.id}, sort: ["updated_at", "desc"])
  end

  def show
    attachment = Attachment.find(params[:id])
    Can.edit?(current_user, attachment) do
      send_file attachment.file.file.file
    end
  end
end
