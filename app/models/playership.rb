class Playership < ActiveRecord::Base
  belongs_to :game
  belongs_to :player, :class_name => "User"

  validates_presence_of :player, :game
  
  named_scope :online, :conditions => ['user.online = ?', true]
  
  def before_create
    if self.class.first(:conditions => {:game_id => game.id}).nil?
      self[:owner] = true
    end
  end
  
  def inactive!
    active = false
    save
  end
  
  # Return the next/previous player in the circle (1 attacks 2 attacks 3 attacks 1)
  def next
    @next ||= begin
      options = {:order => :player_id, :conditions => ['user.online = ? AND player_id > ?', true, player_id]}
      (self.class.find_by_game_id(game_id, options) || self.class.online.first).player
    end
  end
  
  def previous
    @previous ||= begin
      options = {:order => :player_id, :conditions => ['user.online = ? AND player_id < ?', true, player_id]}
      (self.class.find_by_game_id(options) || self.class.online.last).player
    end
  end
end
