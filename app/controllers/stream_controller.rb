class StreamController < ApplicationController
  skip_before_filter :verify_authenticity_token
  
  def part
    if request_valid?
      msg = message("left")
      msg = javascript_chat_message(msg)
      Juggernaut.send_to_channels(msg, params[:channels])
      
      params[:channels].each do |channel|
        unless channel.to_i.zero?
          game = Game.find(channel.to_i)
          
          if game.started_at.nil? && game.owner == request_user
            js = 'alert("The owner has left the game..."); window.location = "/";'
            Juggernaut.send_to_channel(js, channel);
          end
          
          playership = game.playerships.find_by_player_id(params[:client_id])
          logger.info("Removing player #{params[:client_id]} from game #{channel} with playership: #{playership.inspect}")
          playership.destroy unless playership.nil?
        end
      end
    end
    render :nothing => true
  end
  
  def disconnect
    request_user.offline! if request_valid?
    render :nothing => true
  end
  
  def join
    if request_valid?
      request_user.online!
      
      msg = message("joined")
      msg = javascript_chat_message(msg)
      Juggernaut.send_to_channels(msg, params[:channels])
        
      render :nothing => true
    else
      render :text => "403", :status => 403
    end
  end
  
  private
  def request_valid?
    @request_valid ||= begin
      @session = session_data_by_id(params[:session_id])
      @session && @session[:user_id].to_i == params[:client_id].to_i
    end
  end
  
  def message(action)
    render_to_string :partial => 'messages/status', :locals => {:player => request_user, :action => action}
  end
  
  def request_user
    @request_user ||= User.find(@session[:user_id]) if request_valid?
  end
end