class Playership < ActiveRecord::Base
  belongs_to :game
  belongs_to :player, :class_name => "User"
  
  validates_associated :player, :game
  validates_presence_of :player, :game
  
  def before_create
    if self.class.first(:conditions => {:game_id => game.id}).nil?
      self[:owner] = true
    end
  end
end
