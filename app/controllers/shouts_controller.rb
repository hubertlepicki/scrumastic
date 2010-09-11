#encoding: utf-8

class ShoutsController < ProjectScopedController
  def index
    @shouts = @project.shouts.find(:all, :sort => ["created_at", "desc"])
    render :layout => false
  end

  def create
    @shout = Shout.new(params[:shout])
    @shout.user = current_user
    @shout.project = @project
    @shout.save
  end
end
