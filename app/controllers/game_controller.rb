class GameController < ApplicationController
  before_filter :login_required # you have to be logged in to join a game
  
  # Check that the current user is in a game, unless they are joining or creating one
  before_filter :check_current_game, :except => [:join, :create]

  # /game
  def index
    # Preload a few messages from channel history, if their are any and display
    # them oldest to newest...
    @messages = Message.history.for_channel(current_game).reverse
  end
  
  # /game/create
  # Create a new game that the current user is the owner of and then
  # redirect to the game
  def create
    current_user.create_game
    redirect_to game_path
  end

  # /game/join/:id
  # Joins the given game, gives us some lives, and redirects us to 
  # the game page
  def join
    game = Game.find(params[:id])
    
    raise "Game already started" unless game.open?
    
    # Only add the player to the game if they aren't already in it
    game.join(current_user) unless game.has_player?(current_user)
    current_user.lives = 25
    current_user.save!
    redirect_to game_path
  rescue    
    flash[:error] = "That is not a game that can be joined"
    redirect_to lobby_path
  end
  
  # /game/status_update?gold=:gold&lives=:lives&income=:income
  # AJAX pings this address to give updates on clients status
  def status_update
    current_user.gold = params[:gold]
    current_user.lives = params[:lives]
    current_user.income = params[:income]

    # Send out the updated user list to all clients
    update_user_list(current_game.id)
  end
  
  # /game/attack?monster=:monster
  # Game posts to this address to send a moster to his victim
  def attack
    monster = params[:monster]
    
    # attacker sends the monster to the victim
    attacker = current_user
    victim = attacker.next.player
    
    logger.info("#{attacker}:#{attacker.id} is attacking " +
      "#{victim}:#{victim.id} with monster " +
      "#{monster} in game #{current_game.id}")

    # Send the monster to the victim
    Juggernaut.send_to_client_on_channel("js_isAttacked('#{monster}');", victim.id, current_game.id )
    
    render :nothing => true
  end
  
  # /game/life_lost
  # Each time the game registers a player lost a life, this address is pinged so that
  # the attacker can earn the life
  def life_lost
    # if we are attacking ourselves, don't give our life back (otherwise it will never end)
    unless current_user == current_user.previous.player
      # Render the status message and push it to all clients
      message = render_to_string :partial => 'messages/gained_a_life', 
        :locals => {:user_1 => current_user.previous.player, :user_2 => current_user}
      send_status_message(message)  
        
      # Attacker gains the life that their victim lost
      attacker = current_user.previous.player
      life_gained(attacker)
    end
  end  
  
  # /game/start
  # Only the game owner can start the game.
  # Starting the game locks it from new entries and tells all clients to load
  # the game SWFs onto the main stage.
  def start
    if request.xhr? && current_user.owns_game?(current_game) && current_game.open?
      current_game.start!
      Juggernaut.send_to_channel('embedGame();', current_game.id);
    else
      raise "Already started or not owner of game..."
    end
    
    render :nothing => true
  end
  
  protected
  # If a user is not in a game when this is called, they'll be redirected to the lobby chat
  def check_current_game
    if current_game.nil?
      flash[:error] = "You must be in a game to do that..."
      redirect_to lobby_path
    end
  end
  
  # Any user who gets passed to this will have their life count incremented in their current game
  def life_gained(user)
    message = "gameSwf().fl_lifeGained();"
    Juggernaut.send_to_client_on_channel(message, user.id, current_game.id)
  end
end
