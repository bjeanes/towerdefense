class MessagesController < ApplicationController
  
  # /messages/create
  def create
    @message = Message.new(params[:message])
    @message.sender = current_user

    if @message.save!
      # If the message was saved correctly (i.e. was valid),
      # we can send it to the channel.
      send_message
    end
    
    render :nothing => true
  end
  
  protected
  
  # Sends the message to the channel
  def send_message
    message = render_to_string(:partial => 'messages/message', :object => @message)
    Juggernaut.send_to_channel(javascript_chat_message(message), @message.channel_id)
  end
end
