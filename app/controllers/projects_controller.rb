# encoding: UTF-8

class ProjectsController < AuthenticatedController
  respond_to :html, :json
  
  before_filter :find_user_owned_project, except: [:new, :index, :create, :show]

  def index
    @projects = [ {product_owner_id: current_user.id},
                  {scrum_master_id: current_user.id},
                  {team_member_ids: current_user.id.to_s},
                  {stakeholder_ids: current_user.id.to_s}
    ].inject([]) { |all, cond| all + Project.where(cond)}
    @owned_projects = Project.where(owner_id: current_user.id)
  end

  def new
    respond_with(@project = Project.new)
  end

  def create
    respond_with(@project = Project.create(params[:project].merge(owner_id: current_user.id)))
  end

  def edit
    Can.edit?(current_user, @project) do
      respond_with(@project)
    end
  end

  def show
    @project = Project.find(params[:id])
    Can.see?(current_user, @project) do
      respond_with(@project)
    end
  end

  def update
    Can.edit?(current_user, @project) do
      @project.update_attributes(params[:project].merge(owner_id: current_user.id))
      respond_with(@project)
    end
  end

  def destroy
    Can.destroy?(current_user, @project) do
      @project.destroy
      redirect_to projects_path
    end
  end

  protected
  def find_user_owned_project
    @project = current_user.projects.find(params[:id])
  end
end
