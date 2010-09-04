class TimeLogEntriesController < ProjectScopedController
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

  def index
    query = {sort: ["created_at", "desc"], page: params[:page], 
             per_page: 20, :conditions => {:project_id => @project.id}}

    if params[:from] && params[:to]
      query[:conditions][:created_at.gte] = Time.parse params[:from]
      query[:conditions][:created_at.lte] = Time.parse params[:to]
    end
    @time_log_entries = TimeLogEntry.paginate(query)
  end

  private

  def find_user_story
    @user_story = @project.user_stories.find(params[:user_story_id]) 
  end
end
