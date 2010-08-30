# encoding: utf-8

class ProjectScopedController < AuthenticatedController
  before_filter :find_project

  protected

  # Finds project and sets @project instance variable by params[:project_id]
  def find_project
    @project = Project.find(params[:project_id])
  end

end