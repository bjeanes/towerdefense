class User < ActiveRecord::Base
  COLOURS = %w{ 
    0000ff ff00ff 0D9997
    996429 18990B 6E4099
    104599 999000 990900
    426B99 }

  validates_presence_of :username, :session_id
  validate :unique_among_active

  named_scope :active, lambda { { :conditions => ['last_active_at > ?', 2.minutes.ago], :order => 'created_at DESC' } }
  belongs_to :current_game, :class_name => 'Game'
  
  def active!
    self.last_active_at = Time.zone.now
    save!
  rescue # if we can't save, then this username is probably in use
    destroy
  end
  
  def color; colour; end
  
  protected
  
  def before_create
    self.colour = COLOURS[rand(COLOURS.size)]
    self.last_active_at = Time.zone.now
  end
  
  def unique_among_active
    conditions = ["id != ?", id] unless new_record?
    
    unless self.class.active.find_by_username(username, :conditions => conditions).nil?
      errors.add :username, "must be unique among currently logged in users"
    end
  end
end