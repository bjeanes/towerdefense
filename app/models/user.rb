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
  
  named_scope :online, :conditions => {:online => true}, :order => :login
  
  def self.authenticate(login, password)
    return nil if login.blank? || password.blank?
    u = find_by_login(login) # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end

  def login=(value)
    write_attribute :login, (value ? value.downcase : nil)
  end
  
  def online!
    online = true
    save!
  end
  
  def offline!
    online = false
    save!
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