class StreamController < ApplicationController
  skip_before_filter :verify_authenticity_token
  
  def part
    if request_valid?
      # This should remove us from a game/channel
      request_user.offline!
    
      # should do a render juggernaut and tell all user lists in parted channels to refresh
      message = "<div class=\"message\">-&gt; #{request_user} has disconnected</div>"
      render :juggernaut => {:type => :send_to_channels, :channels => params[:channels]} do |page|
        # have to use @request_user here else get method_missing (block scope is in ActionView)
        page.insert_html :bottom, 'messages', message
        page.replace_html 'users', :partial => 'lobby/user_list', :locals => {:users => User.online}
      end
    end
    render :nothing => true
  end
  
  def disconnect
    request_user.offline! if request_valid?
    
    message = "<div class=\"message\">-&gt; #{request_user} has quit</div>"
    render :juggernaut => {:type => :send_to_all} do |page|
      # have to use @request_user here else get method_missing (block scope is in ActionView)
      page.insert_html :bottom, 'messages', message
      page.replace_html 'users', :partial => 'lobby/user_list', :locals => {:users => User.online}
    end
    render :nothing => true
  end
  
  def join
    if request_valid?
      request_user.online!
      
      message = "<div class=\"message\">-&gt; #{request_user} has connected</div>"
      
      # This should add the request_user to a game/lobby
      
      # this should push current user name onto all channel user lists
      render :juggernaut => {:type => :send_to_channels, :channels => params[:channels]} do |page|
        # have to use @request_user here else get method_missing (block scope is in ActionView)
        page.insert_html :bottom, 'messages', message
        page.replace_html 'users', :partial => 'lobby/user_list', :locals => {:users => User.online}
      end
      
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