class GameController < ApplicationController
  before_filter :login_required
  before_filter :check_current_game, :except => :join
  
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
  
  def status_update
    # update_user_list(current_game.id)
    render :nothing => true
  end
  
  def attack
    monster = params[:monster]
    Juggernaut.send_to_client_on_channel("js_isAttacked('#{monster}');", current_user.next.id, current_game.id )
    render :nothing => true
  end
  
  def life_lost
    current_user.lives -= 1
    current_user.next.lives += 1
    
    message = render_to_string :partial => 'messages/gained_a_life', 
      :locals => {:user_1 => current_user.next, :user_2 => current_user}
    life_gained(current_user.next)      
    send_status_message(message)
  end  
  
  def start
    if request.xhr? && current_user.owns_game?(current_game)
      current_game.started_at = Time.now
      current_game.save
    else
      redirect_to game_path
    end
  end
  
  protected
  def check_current_game
    if current_game.nil?
      flash[:error] = "You must be in a game to do that..."
      redirect_to lobby_path
    end
  end
  
  def life_gained(user)
    message = "gameSwf().fl_lifeGained();"
    Juggernaut.send_to_client_on_channel(message, user.id, current_game.id)
  end
end
