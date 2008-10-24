# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include AuthenticatedSystem
  helper :all

  # We don't want user passwords being logged
  filter_parameter_logging :password, :password_confirmation
  
  protected
  # Checks if a player is in a given game by asking the Juggernaut server if they have 
  # an open socket registered to that session
  def in_channel?(channel)
    Juggernaut.client_in_channel?(current_user.id, channel)
  end
  
  # Pushes an updated user listing to members in a game (updates stats, order, who is winning, etc)
  def update_user_list(channels = 0)
    channels = [*channels].flatten
    
    channels.each do |channel|
      # Find all players in the given channel ordered with highest lives first (winner)
      users = Game.find(channel.to_i).playerships.all(:order => 'lives DESC')
      
      # Render the user list into HTML to send to client
      user_list = render_to_string :partial => 'shared/user_list', 
        :locals => {:users => users}
        
      # Send updated HTML to the client javascript for processing
      user_list = 'updateUserList("%s");' % escape_message(user_list)
      Juggernaut.send_to_channel(user_list, channel)
    end
  ensure
    render :nothing => true
  end
  
  # Sends status messages to the log windows
  # e.g. "bjeanes has joined the game"
  def send_status_message(msg)
    Juggernaut.send_to_channel(javascript_chat_message(msg), current_game.id)
    render :nothing => true
  end
  
  # Take a JS-safe string and format it into a message to send to client
  def javascript_chat_message(message)
    'receiveMessage("%s");' % escape_message(message)
  end
  
  # Encode a message to be sent to server and intepreted by javascript
  def escape_message(message)
    message.gsub(/\"/, '\"').gsub(/\n|\r/,'')
  end
  
  # Find a session data by a session ID (so that Juggernaut can access session data for other clients)
  def session_data_by_id(id)
    CGI::Session::ActiveRecordStore::Session.find_by_session_id(id).data
  rescue
    nil
  end
  
  # Return the game that the current user is in, or nil
  def current_game
    current_user.current_game
  rescue
    nil
  end
end
