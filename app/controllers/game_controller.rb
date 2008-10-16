class GameController < ApplicationController
  before_filter :login_required
  
  def index
    # Display current game or redirect to lobby
    @messages = Message.history.for_channel(current_user.current_game).reverse
  rescue
    flash[:error] = "You must join a game"
    redirect_to lobby_path
  end
  
  def join
    game = Game.find(params[:id])
    game.join(current_user)
    
    redirect_to game_path
  rescue
    flash[:error] = "That is not a game that can be joined"
    redirect_to lobby_path
  end
end
