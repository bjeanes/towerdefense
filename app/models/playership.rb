# This is a join model representing the connection between a user and a game

class Playership < ActiveRecord::Base
  # Players are put in an order so that .next and .previous can be used
  # to determine who a given player is attacking or being attacked by
  acts_as_ordered :order => 'id', :wrap => true  
  
  belongs_to :game
  belongs_to :player, :class_name => "User"

  # a Playership can not exist without a player and a game
  validates_presence_of :player, :game
  
  # Delegate common methods to the player
  delegate :to_s, :login, :colour, :online, :to => :player
  
  # If this is the first playership created for a given game,
  # then the current user must be the owner
  def before_create
    if self.class.first(:conditions => {:game_id => game.id}).nil?
      self[:owner] = true
    end
  end
end
