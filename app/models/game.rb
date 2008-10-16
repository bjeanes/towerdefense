class Game < ActiveRecord::Base
  has_many :playerships, :dependent => :destroy
  has_many :players, :through => :playerships
  
  validates_associated :playerships
  
  # Games that can be joined
  named_scope :open, :conditions => 'started_at IS NULL', :include => :players
  
  # Games that are being played but have not finished
  named_scope :active, :conditions => 'concluded_at IS NULL AND started_at IS NOT NULL', :include => :players
  
  # Games that have finished
  named_scope :concluded, :conditions => 'concluded_at IS NULL'
  
  def concluded?
    !concluded_at.nil?    
  end
end
