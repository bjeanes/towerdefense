class GameController < ApplicationController
  before_filter :login_required
  
  def index
    # Display current game or redirect to lobby
    @messages = Message.history.for_channel(current_user.game).reverse
  end
  
  def join
    # can only join a game if:
    #   game_id provided
    #   game is open
    #   user has not previously left the game
    #   user is not already in game
  end
end
