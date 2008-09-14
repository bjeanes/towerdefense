class GamesController < ApplicationController
  before_filter :user_is_active, :except => :login

  def index
    redirect_to :action => 'login' unless logged_in?
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
      page.insert_html :bottom, 'chat_data', "<span class=\"message\"><span class=\"username\">#{h(current_user.username)}:</span>#{h params[:chat_input]}</span>"
    end
    render :nothing => true
  end
  
  private 
  def user_is_active
    current_user.active! if current_user
  end
  
end