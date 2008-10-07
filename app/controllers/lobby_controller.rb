class LobbyController < ApplicationController
  before_filter :login_required
  
  def index
    @messages = Message.lobby.all(:limit => 5).reverse
  end
end
