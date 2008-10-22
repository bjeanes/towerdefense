# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include AuthenticatedSystem
  helper :all
  # protect_from_forgery :secret => '94a45eddfc4f90ebf9470b5d5271ad35'
  filter_parameter_logging :password, :password_confirmation
  
  protected
  def in_channel?(channel)
    Juggernaut.client_in_channel?(current_user.id, channel)
  end
  
  def update_user_list(channels = 'lobby')
    channels = [*channels].flatten
    
    channels.each do |channel|
      users = User.in(channel)
      Juggernaut.send_to_channel("...", channel)
    end
    
    render :nothing => true
  end
  
  
  
  def send_status_message(msg)
    Juggernaut.send_to_channel(javascript_chat_message(msg), current_game.id)
    render :nothing => true
  end
  
  def javascript_chat_message(message)
    'receiveMessage("%s");' % escape_message(message)
  end
  
  def escape_message(message)
    message.gsub(/\"/, '\"').gsub(/\n|\r/,'')
  end
  
  def session_data_by_id(id)
    CGI::Session::ActiveRecordStore::Session.find_by_session_id(id).data
  rescue
    nil
  end
  
  def current_game
    current_user.current_game
  rescue
    nil
  end
end
