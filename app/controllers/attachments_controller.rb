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
    @attachments = Attachment.paginate(conditions: {project_id: @project.id}, sort: ["updated_at", "desc"],
                                       page: params[:page], per_page: 10)
  end

  def show
    attachment = Attachment.find(params[:id])
    Can.edit?(current_user, attachment) do
      if params[:style] == "thumb"
        safer_send_file attachment.file.thumb.file.file
      else
        safer_send_file attachment.file.file.file
      end
    end
  end

  def destroy
    attachment = Attachment.find(params[:id])
    Can.edit?(current_user, attachment) do
      attachment.destroy
      redirect_to [@project, :attachments]
    end
  end
end
