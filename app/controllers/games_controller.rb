class GamesController < ApplicationController
  before_filter :user_is_active, :except => :login
  before_filter :authenticate, :except => [:login, :take_login]

  def show    
    render :juggernaut => {:type => :send_to_all} do |page|
      page.insert_html :bottom, 'messages', 
        "<span class=\"notice\" style=\"color:##{current_user.colour}\">
            #{h(current_user.username)} has signed in
        </span>"
      page << "$('messages').scrollTop = $('messages').scrollHeight;"
    end
  end
  
  def login
    @user = User.new
    render :layout => false
  end

  def take_login    
    @user = User.new
    @user.session_id = session.session_id
    @user.username = params[:username]
    
    if @user.save
      redirect_to :action => 'index'
    else
      render :action => 'login', :layout => false
    end
  end
	
  def send_data
    current_user.active!
    
    render :juggernaut => {:type => :send_to_all} do |page|
      page.insert_html :bottom, 'messages', 
        "<span class=\"message\">
          <span class=\"username\" style=\"color:##{current_user.colour}\">
            #{h(current_user.username)}:
          </span>
          #{h params[:chat_input]}
        </span>"
      page << "$('messages').scrollTop = $('messages').scrollHeight;"
    end
    render :nothing => true
  end
  
  private
  def user_is_active
    current_user.active! if current_user
  # rescue
  #   redirect_to :action => 'login'
  end
  
  def authenticate
    redirect_to :action => 'login' unless logged_in?
  end
end
