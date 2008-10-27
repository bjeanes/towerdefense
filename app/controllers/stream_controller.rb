=begin
  This entire file deals with the Juggernaut server for 
  pushing messages to clients using COMET instead of standard
  HTTP requests. This means there is next to delay between messages
  being sent and received, other than the network latency. This
  class is how Juggernaut tells the games when a client joins/leaves
  and triggers actions in the main server to send messages or update
  the database accordingly (i.e. "User 1 has left the channel...")
=end

class StreamController < ApplicationController
  # This is called as soon as they close a channel window (such as the lobby or a game)
  def part
    if request_valid?
      msg = message("left")
      msg = javascript_chat_message(msg)
      
      # Tell all parted channels that the user has left...
      Juggernaut.send_to_channels(msg, params[:channels])
      
      params[:channels].each do |channel|
        # For all channels except the lobby
        # remove the player from the associated game
        unless channel.to_i.zero?
          game = Game.find(channel.to_i)
          
          # If the owner left the game before he marked it as started,
          # then send everyone back to the lobby because the game can never
          # be started...
          if game.started_at.nil? && game.owner == request_user
            js = 'alert("The owner has left the game..."); window.location = "/";'
            Juggernaut.send_to_channel(js, channel);
          end
          
          # Remove the player from the game they just left so that their attacker
          # can attack the next in line
          playership = game.playerships.find_by_player_id(params[:client_id])
          logger.info("Removing player #{params[:client_id]} from game #{channel} with playership: #{playership.inspect}")
          # playership.destroy unless playership.nil?
        end
      end
    end
    render :nothing => true
  end
  
  # This is called when the client is connected to 0 channels, and therefore we can 
  # mark them as offline (which removes them from all games)
  def disconnect
    request_user.offline! if request_valid?
    render :nothing => true
  end
  
  # Juggernaut calls this when ever a user enters a game/channel and passes
  # their session id, user id, and an array of channels that they just joined
  def join
    if request_valid?
      request_user.online!
      
      msg = message("joined")
      msg = javascript_chat_message(msg)
      
      # Inform all joined channels that the user has joined
      Juggernaut.send_to_channels(msg, params[:channels])
        
      render :nothing => true
    else
      # Prevent the user from joining the channel if the request is not
      # from a valid session/user combination
      render :text => "403", :status => 403
    end
  end
  
  private
  def request_valid?
    # Sets up the session data and returns whether or not the Juggernaut is
    # a real and valid user (i.e. does the session match up with the user id).
    # Protects against forging game request from the lobby or other sites
    @request_valid ||= begin
      @session = session_data_by_id(params[:session_id])
      @session && @session[:user_id].to_i == params[:client_id].to_i
    end
  end
  
  # Render a status message to a string and return it
  def message(action)
    render_to_string :partial => 'messages/status', :locals => {:player => request_user, :action => action}
  end
  
  # Return a User object that represents the Juggernaut client
  def request_user
    # request_valid? is called first which creates a @session instance
    # variable which acts like the global session object of a normal request.
    @request_user ||= User.find(@session[:user_id]) if request_valid?
  end
end