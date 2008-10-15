class Playership < ActiveRecord::Base
  belongs_to :game
  belongs_to :player, :class_name => "User"
  
  validates_associated :player, :game
  validates_presence_of :player, :game
end
