# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include AuthenticatedSystem
  helper :all
  protect_from_forgery :secret => '94a45eddfc4f90ebf9470b5d5271ad35'
  filter_parameter_logging :password, :password_confirmation
  
  protected
  def in_channel?(channel)
    Juggernaut.client_in_channel?(current_user.id, channel)
  end
  
  def send_message
    message = render_to_string(:partial => 'messages/message', :object => @message)
    message = 'receiveMessage("%s");' % message.gsub(/\"/, '\"').gsub(/\n|\r/,'') # escape double quotes and remove new lines
    logger.debug(message)
    
    Juggernaut.send_to_channel(message, @message.channel)
    
    render :nothing => true
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
