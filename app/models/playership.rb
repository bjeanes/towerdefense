class Playership < ActiveRecord::Base
  belongs_to :game
  belongs_to :player, :class_name => "User"

  validates_presence_of :player, :game
  
  def before_create
    if self.class.first(:conditions => {:game_id => game.id}).nil?
      self[:owner] = true
    end
  end
  
  # Return the next/previous player in the circle (1 attacks 2 attacks 3 attacks 1)
  def next
    @next ||= begin
      options = {:order => :player_id, :conditions => ['player_id > ?', player_id]}
      (self.class.find_by_game_id(game_id, options) || self.class.first).player
    end
  end
  
  def previous
    @previous ||= begin
      options = {:order => :player_id, :conditions => ['player_id < ?', player_id]}
      (self.class.find_by_game_id(options) || self.class.last).player
    end
  end
end
