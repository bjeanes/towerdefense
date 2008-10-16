class GameController < ApplicationController
  before_filter :login_required
  
  def index
    # Display current game or redirect to lobby
    @game = current_user.current_game
    @messages = Message.history.for_channel(@game).reverse
  rescue
    flash[:error] = "You must join a game"
    redirect_to lobby_path
  end
  
  # TODO - make sure we are removed from all other games before joining a new one
  def join
    game = Game.find(params[:id])
    game.join(current_user)
    
    redirect_to game_path
  rescue
    # TODO - redirect to game_path if we are already in this game, otherwise lobby_path
    
    flash[:error] = "That is not a game that can be joined"
    redirect_to lobby_path
  end
end
