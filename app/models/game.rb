class Game < ActiveRecord::Base
  has_many :playerships, :dependent => :destroy
  has_many :players, :through => :playerships
  
  # Games that can be joined
  named_scope :open, :conditions => 'started_at IS NULL', :include => :players
  
  # Games that are being played but have not finished
  named_scope :active, :conditions => 'concluded_at IS NULL AND started_at IS NOT NULL', :include => :players
  
  # Games that have finished
  named_scope :concluded, :conditions => 'concluded_at IS NOT NULL'
  
  # can only join a game if:
  #   game_id provided
  #   game is open
  #   user has not previously left the game
  #   user was kicked out
  #   user is not already in game
  def join(user)  
    raise "Can not join this game" if new_record? || !open?
    
    players << user
    save!
  end
  
  def has_player?(player)
    players.include? player
  end
  
  def owner
    playerships.first(:conditions => {:owner => true}).player
  rescue
    destroy
  end
  
  def start!
    self.started_at = Time.now
    save!
  end
  
  # States:
  def open?
    started_at.nil?
  end
  
  def active?
    !started_at.nil? && concluded_at.nil?
  end
  
  def concluded?
    !concluded_at.nil?
  end
end
