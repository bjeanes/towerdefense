class StreamController < ApplicationController
  def part
    # This should remove us from a game/channel
  end
  
  def disconnect
    request_user.offline! if request_valid?
  end
  
  def join
    if request_valid?
      request_user.online!
      
      # This should add the request_user to a game/lobby
      
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
  
  def request_user
    @user ||= User.find(@session[:user_id]) if request_valid?
  end
end