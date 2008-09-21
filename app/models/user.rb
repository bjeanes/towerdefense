class User < ActiveRecord::Base
  COLOURS = %w{ 
    0000ff ff00ff 0D9997
    996429 18990B 6E4099
    104599 999000 990900
    426B99 }

  validates_presence_of :username, :session_id
  
  def active!
    last_active_at = Time.now
    save
  end
  
  def color; colour; end
  
  def before_create
    self.colour = COLOURS[rand(colours.size)]
  end
end
