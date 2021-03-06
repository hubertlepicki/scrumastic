# encoding: UTF-8

class SprintLogEntriesController < ProjectScopedController
  respond_to :json

  def index
    from = Time.at(params[:from].to_i)
    to = Time.at(params[:to].to_i)
    respond_with @sprint_log_entries = SprintLogEntry.where(project_id: @project.id, :created_at.gte => from, :created_at.lte => to).asc(:created_at)
  end
end
