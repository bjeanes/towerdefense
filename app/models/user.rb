class User < ActiveRecord::Base
  validates_presence_of :username, :session_id
  
  def active!
    last_active_at = Time.now
    save
  end
end
