class LobbyController < ApplicationController
  before_filter :login_required
  
  # /lobby
  def index
    # Lobby history...
    @messages = Message.history.for_lobby.reverse
  end
  
  # Routing set up so that / goes to this URL
  # Consequence is that / redirects to /lobby
  def redirect_to_lobby
    redirect_to :action => :index
  end
end
