class WebsocketConnectionsController < ApplicationController
  skip_before_filter :verify_authenticity_token
  def create
    user = User.find(params[:client_id])
    if (user.password_salt == params[:client_secret]) && user.role_in_project(Project.find(params[:channels]["0"]))
      head :ok
    else
      head :method_not_allowed
    end
  end
end

