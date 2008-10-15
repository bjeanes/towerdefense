class Game < ActiveRecord::Base
  has_many :playerships, :dependent => :destroy
  has_many :players, :through => :playerships
  
  validates_associated :playerships
end
