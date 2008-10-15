class Playership < ActiveRecord::Base
  has_one :game
  has_one :player, :class_name => "User"
  
  validates_associated :player, :game
  validates_presence_of :player, :game
end
