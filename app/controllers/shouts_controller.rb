#encoding: utf-8

class ShoutsController < ProjectScopedController
  def index
    @shouts = @project.shouts.find(:all, sort: ["created_at", "desc"], limit: 10)
    render layout: false
  end

  def create
    @shout = Shout.new params[:shout]
    @shout.user = current_user
    @shout.project = @project
    @shout.save

    publish_shout @shout
  end

  private

  def publish_shout(shout)
    Socky.send render_to_string(action: "publish_shout"), to: {channels: [@project.id]}
  end
end
