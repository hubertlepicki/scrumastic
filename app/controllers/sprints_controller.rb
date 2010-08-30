# encoding: UTF-8

class SprintsController < ProjectScopedController
  layout false
  before_filter :find_sprint, except: [:index, :create]
  
  def destroy
    Can.edit_sprints_for?(current_user, @project) do
      @sprint.destroy
    end
  end

  def create
    Can.edit_sprints_for?(current_user, @project) do
      @sprint = Sprint.create(params[:sprint].merge(project_id: @project.id))
    end
  end

  def index
    Can.see?(current_user, @project) do
      @sprints = @project.sprints.find(:all, :conditions => {}, :sort => [:start_date, :desc])
    end
  end

  def update
    Can.edit_sprints_for?(current_user, @project) do
      @sprint.update_attributes(params[:sprint].merge(project_id: @project.id))
    end
  end

  def show
    render json: @sprint.to_json(methods: :sprint_log_entries)
  end

  protected

  def find_sprint
    @sprint = @project.sprints.find(:first, :conditions => {:id => params[:id]})
  end
end
