class GamesController < ApplicationController
  before_filter :user_is_active, :except => :login

  def index
    unless logged_in?
      redirect_to :action => 'login'
      return
    end
    
    render :juggernaut => {:type => :send_to_all} do |page|
      page.insert_html :bottom, 'chat_data', 
        "<span class=\"notice\" style=\"color:##{current_user.colour}\">
            #{h(current_user.username)} has signed in
        </span>"
    end
  end

  def take_login
    @user = User.new
    @user.session_id = session.session_id
    @user.username = params[:username]
    @user.active!
    
    if @user.save
      redirect_to :action => 'index'
    else
      render :action => :login
    end
  end
	
  def send_data
    render :juggernaut => {:type => :send_to_all} do |page|
      page.insert_html :bottom, 'chat_data', 
        "<span class=\"message\">
          <span class=\"username\" style=\"color:##{current_user.colour}\">
            #{h(current_user.username)}:
          </span>
          #{h params[:chat_input]}
        </span>"
      page << "$('chat_data').scrollTop = $('chat_data').scrollHeight;"
    end
    render :nothing => true
  end
  
  private
  def user_is_active
    current_user.active! if current_user
  end
  
end