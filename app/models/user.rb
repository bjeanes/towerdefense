require 'digest/sha1'

class User < ActiveRecord::Base
  include Authentication
  include Authentication::ByPassword
  include Authentication::ByCookieToken

  validates_presence_of     :login
  validates_length_of       :login,    :within => 3..40
  validates_uniqueness_of   :login
  validates_format_of       :login,    :with => Authentication.login_regex, :message => Authentication.bad_login_message
  
  attr_accessible :login, :password, :password_confirmation
  
  has_many :playerships, :foreign_key => 'player_id', :dependent => :destroy
  has_one :game, :through => :playerships, :conditions => ["playerships.owner = ?", true], :order => "games.created_at desc"
  
  has_many :games, :through => :playerships
  
  named_scope :online, :conditions => {:online => true}, :order => :login
  
  delegate :next, :previous, :to => :playership
  
  # Could use delegates but they don't seem to work as nice for setters (cache the getters)
  %w{income gold lives}.each do |c|
    define_method(c) do
      begin
        playership.send c 
      rescue
        0
      end
    end
    
    define_method("#{c}=") do |new_value|
      begin
        playership.update_attribute(c, new_value)
        playership.reload
        new_value
      rescue
        nil
      end
    end
  end
  
  def lives_changed(new_lives)
    old_lives = self.lives
    self.lives = new_lives.to_i
    (old_lives + new_lives).to_i
  end
  
  def self.authenticate(login, password)
    return nil if login.blank? || password.blank?
    u = find_by_login(login) # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end

  def current_game
    games.active.first || games.open.first
  end
  
  def playership
    @playership ||= playerships.find_by_game_id(current_game.id)
  rescue
    nil
  end
  
  def owns_game?(game = self)
    current_game.owner == game
  rescue
    false
  end

  def login=(value)
    write_attribute :login, (value ? value.downcase : nil)
  end
  
  def online!
    self.online = true
    save!
  end
  
  def offline!
    self.online = false
    self.playerships.map(&:inactive!)
    save!
  end
  
  # Creates a game, adds the current user as a player, and sets the player as the game owner
  def create_game
    if game.nil? || game.concluded?
      p = playerships.build(:owner => true)
      p.game = Game.new(:name => "#{login}'s Game")
    
      p.save && self.game(true) # load the new game
    else
      false
    end
  end
  
  def to_s; login; end
  
  protected
  
  def before_create
    self.colour = random_colour
  end
  
  def random_colour
    @colours ||= %w{ 
      0000ff ff00ff 0D9997
      996429 18990B 6E4099
      104599 999000 990900
      426B99 }
      
    @colours.rand
  end
end