module MessagesHelper
  def user(sender)
    "<span class=\"user\" style=\"color:##{sender.colour}\">
      #{sender}
    </span>"
  end
  
  def timestamp(time = Time.now)
    "[#{time.strftime("%d %b %y @ %H:%M")}]"
  end
end