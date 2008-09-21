class User < ActiveRecord::Base
  COLOURS = %w{ 
    0000ff ff00ff 0D9997
    996429 18990B 6E4099
    104599 999000 990900
    426B99 }

  validates_presence_of :username, :session_id

  named_scope :active, lambda { { :conditions => ['last_active_at > ?', 2.minutes.ago] } }
  
  def active!
    self.last_active_at = Time.zone.now
    save
  end
  
  def color; colour; end
  
  def before_create
    self.colour = COLOURS[rand(colours.size)]
    self.last_active_at = Time.zone.now
  end
end
