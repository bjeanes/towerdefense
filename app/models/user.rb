require 'digest/sha1'

class User < ActiveRecord::Base
  include Authentication
  include Authentication::ByPassword
  include Authentication::ByCookieToken

  # User requirements before it can be saved to a database
  validates_presence_of     :login
  validates_length_of       :login,    :within => 3..40
  validates_uniqueness_of   :login
  validates_format_of       :login,    :with => Authentication.login_regex, :message => Authentication.bad_login_message
  
  # Create getters/setters for following variables
  attr_accessible :login, :password, :password_confirmation
  
  has_many :playerships, :foreign_key => 'player_id', :dependent => :destroy
  
  # Has one owned game (at a time)
  has_one :game, :through => :playerships, :conditions => ["playerships.owner = ?", true], :order => "games.created_at desc"
  
  # Has many games that they have played
  has_many :games, :through => :playerships
  
  # User.online - finds all online users ordered by login name
  named_scope :online, :conditions => {:online => true}, :order => :login
  
  delegate :next, :previous, :to => :playership
  
  # Metaprogramming method to define getters and setters for income, gold, and lives
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
  
  def owns_game?(game)
    game.owner == self
  rescue
    false
  end
  
  def online!
    self.online = true
    save!
  end
  
  def offline!
    self.online = false
    self.playerships.destroy_all
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
  
  # When a user is created, we need to give them a random colour
  # for display in lists and chat messages
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