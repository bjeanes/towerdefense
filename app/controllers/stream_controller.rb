class StreamController < ApplicationController
  %w{part disconnect}.each do |action|
    define_method(action) do
      render :text => ""
    end
  end
  
  def join
    session = session_data_by_id(params[:session_id])
    unless session && session[:user_id].to_i == params[:client_id].to_i
      logger.debug("[Juggernaut] client tried to connect with invalid session_id")
      logger.debug("  session:    #{session.inspect}")
      render :text => "403", :status => 403
    else
      render :nothing => true
    end
  end
end