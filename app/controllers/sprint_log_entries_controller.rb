class SprintLogEntriesController < ProjectScopedController
  before_filter :find_user_story, :only => [:start_work, :stop_work]

  def start_work
    TimeLogEntry.create(user: current_user, project: @project, user_story: @user_story)
    redirect_to :back
  end

  def stop_work
   tle = current_user.current_time_log_entry(@project)
   tle.close if tle
   redirect_to :back
  end


  private

  def find_user_story
    @user_story = @project.user_stories.find(params[:user_story_id]) 
  end
end
