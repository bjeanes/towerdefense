class Game < ActiveRecord::Base
  has_many :playerships, :dependent => :destroy
  has_many :players, :through => :playerships
  
  validates_associated :playerships
  
  def concluded?
    !concluded_at.nil?    
  end
end
