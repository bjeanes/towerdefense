class LobbyController < ApplicationController
  before_filter :login_required
  
  def index
    @messages = Message.lobby
  end
end
