class StreamController < ApplicationController
  skip_before_filter :verify_authenticity_token
  
  def part
    if request_valid?
      request_user.offline!
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
    @request_user ||= User.find(@session[:user_id]) if request_valid?
  end
end