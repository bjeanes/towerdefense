class Game < ActiveRecord::Base
  has_many :playerships, :dependent => true
  has_many :players, :through => :playerships
  
  validates_associated :playerships
  
  def self.create_with_owner(owner)
    create(:owner => owner)
  end
  
  def owner
    playerships.find{|p| p.owner?}.player
  rescue
    nil
  end
  
  def owner=(owner)
    playership = playerships.build
    playership.player = owner
    playership.owner = true
  end

  protected
  
  def before_save
    self[:name] ||= "#{owner}'s Game"
  end
end
