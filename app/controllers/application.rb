# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => 'f2bff47bdd9be6071e6fb847b9c44c78'
  
  filter_parameter_logging :password
  

  private  
  def current_user
    @current_user ||= User.find_by_session_id(session.session_id)
  end
  
  def logged_in?
    !current_user.nil?
  end
end
