# encoding: UTF-8

class UserStoriesController < ProjectScopedController
  before_filter :find_user_story, :except => [:create, :index, :sort] 

  def create
    Can.edit_user_stories_for?(current_user, @project) do
      @user_story = UserStory.create(params[:user_story].merge(project_id: @project.id))
    end
  end
  
  def destroy
    Can.edit_user_stories_for?(current_user, @project) do
      @user_story.destroy
    end
  end

  def edit
    Can.see?(current_user, @project) do
      
    end
  end

  def index
    Can.see?(current_user, @project) do
      conditions = {
        in_backlog: params[:in_backlog] == "false" ? false : true,
        sprint_id: nil
      }
      @user_stories = @project.user_stories.find(:all, conditions: conditions, sort: [:position, :asc])
    end
  end

  def update
    Can.edit_user_stories_for?(current_user, @project) do
      @user_story.update_attributes(params[:user_story].merge(project_id: @project.id))
    end
  end

  def move_to_incubator
    Can.edit_user_stories_for?(current_user, @project) do
      @user_story.move_to_incubator!
    end
  end

  def move_to_backlog
    Can.edit_user_stories_for?(current_user, @project) do
      @user_story.move_to_backlog!
    end
  end

  def move_to_sprint
    Can.edit_user_stories_for?(current_user, @project) do
      @sprint = @project.sprints.find(:first, conditions: {id: params[:sprint_id]})
      @user_story.move_to_sprint!(@sprint)
    end
  end

  def show
    Can.see?(current_user, @project) do
      redirect_to [:edit, @project, @user_story]
    end
  end

  def sort
    Can.edit_user_stories_for?(current_user, @project) do
      params[:items].each_with_index do |item, index|
        @project.user_stories.find(:first, conditions: {id: item}).update_attributes position: index
      end
    end
    head :ok
  end
  
  protected

  def find_user_story
    @user_story = @project.user_stories.find(:first, conditions: {id: params[:id]})
  end

end
