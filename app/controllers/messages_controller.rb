class MessagesController < ApplicationController
  def create
    @message = Message.new(params[:message])
    @message.sender = current_user

    if @message.save!
      send_message
    end
    
    render :nothing => true
  end
  
  protected
  def send_message
    message = render_to_string(:partial => 'messages/message', :object => @message)
    Juggernaut.send_to_channel(javascript_chat_message(message), @message.channel)
  end
end
