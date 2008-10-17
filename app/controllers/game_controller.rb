class GameController < ApplicationController
  before_filter :login_required
  
  def index
    @messages = Message.history.for_channel(current_game).reverse
  rescue
    flash[:error] = "You must join a game"
    redirect_to lobby_path
  end

  # TODO - make sure we are removed from all other games before joining a new one
  def join
    game = Game.find(params[:id])
    
    game.join(current_user) unless game.has_player?(current_user)
    redirect_to game_path
  rescue    
    flash[:error] = "That is not a game that can be joined"
    redirect_to lobby_path
  end
  
  def start
    if request.xhr? && current_user.owns_game?(current_game)
      current_game.started_at = Time.now
      current_game.save
    else
      redirect_to game_path
    end
  end
end
