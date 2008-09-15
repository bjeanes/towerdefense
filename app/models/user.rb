class User < ActiveRecord::Base
  validates_presence_of :username, :session_id
  
  def active!
    last_active_at = Time.now
    save
  end
  
  def color; colour; end
  
  def before_create
    colours = %w{0 1 2 3 4 5 6 8 9 a b c d e f}
    self.colour = (1..6).to_a.collect{colours[rand(colours.size)]}.join
  end
end
