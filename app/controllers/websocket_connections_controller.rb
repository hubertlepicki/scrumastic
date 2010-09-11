class WebsocketConnectionsController < ApplicationController
  skip_before_filter :verify_authenticity_token
  def create
    head :ok
  end
end

