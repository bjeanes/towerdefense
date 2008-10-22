class Playership < ActiveRecord::Base
  acts_as_ordered :order => 'id', :wrap => true  
  
  belongs_to :game
  belongs_to :player, :class_name => "User"

  validates_presence_of :player, :game
  
  delegate :to_s, :login, :colour, :online, :to => :player
  
  def before_create
    if self.class.first(:conditions => {:game_id => game.id}).nil?
      self[:owner] = true
    end
  end
end
