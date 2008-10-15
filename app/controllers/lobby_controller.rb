class LobbyController < ApplicationController
  before_filter :login_required
  
  def index
    @messages = Message.lobby.all(:limit => 5).reverse
  end
  
  def redirect_to_lobby
    redirect_to :action => :index
  end
end
