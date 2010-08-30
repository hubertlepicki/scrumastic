# encoding: UTF-8

class CommentsController < ProjectScopedController
  before_filter :find_user_story

  before_filter :find_comment, only: [:edit, :show, :update, :destroy]
  respond_to :html, :json

  def index
    Can.see?(current_user, @project) do
      @comments = @user_story.comments.find(:all, conditions: {}, sort: [:created_at, :asc])
    end
  end

  def new
    Can.see?(current_user, @project) do
      respond_with(@comment = Comment.new)
    end
  end

  def create
    Can.see?(current_user, @project) do
      @comment = Comment.create(params[:comment].merge(
          user_id: current_user.id, user_story_id: @user_story.id))

      redirect_to [@project, @user_story]
    end
  end

  def edit
    Can.edit?(current_user, @comment) do
      respond_with(@comment)
    end
  end

  def show
    Can.see?(current_user, @project) do
      respond_with(@comment = @user_story.comments.find(:first, conditions: {id: params[:id]}))
    end
  end

  def update
    Can.edit?(current_user, @comment) do
      @comment.update_attributes(params[:comment].merge(
        user_id: current_user.id, user_story_id: @user_story.id))
      respond_with(@comment)
    end
  end

  def destroy
    Can.edit?(current_user, @comment) do
      @comment.destroy
    end
  end

  protected
  
  def find_comment
    @comment = @user_story.comments.find(:first, conditions: {id: params[:id]})
  end

  # Finds user story in given project
  def find_user_story
    @user_story = @project.user_stories.find(:first, conditions: {id: params[:user_story_id] })
  end
end
