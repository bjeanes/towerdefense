class MessagesController < ApplicationController
  def create
    @message = Message.new(params[:message])
    @message.sender = current_user

    respond_to do |format|
      if in_channel?(@message.channel) && @message.save
        format.js { send_message }
      end
    end
  end
  
  protected
  def send_message
    message = render_to_string(:partial => 'messages/message', :object => @message)
    Juggernaut.send_to_channel(javascript_chat_message(message), @message.channel)
    
    render :nothing => true
  end
end
