class Game < ActiveRecord::Base
  has_many :players, :through => Playerships
  has_one  :owner,   :through => Playerships, :conditions => ["playerships.owner = ?", true]
  
  validates_associated :owner
  validates_presence_of :owner
  
  def self.create_with_owner(owner)
    create(:owner => owner)
  end
  
  protected
  
  def before_create
    self[:name] ||= "#{owner}'s Game"
  end
end
