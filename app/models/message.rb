class Message < ActiveRecord::Base
  belongs_to :sender, :class_name => "User"
  belongs_to :recipient, :class_name => "User"
  
  validates_presence_of :sender_id
  validates_presence_of :recipient_id, :if => :recipient_required?
  
  validates_presence_of :content
  
  validates_presence_of :channel_id, :if => :channel_required?
  
  named_scope :lobby, :conditions => {:kind => 'lobby', :recipient_id => nil}, :order => :created_at
  
  protected
  
    def recipient_required?
      self[:kind] == 'game'
    end
    
    def channel_required?
      self[:kind] != 'lobby'
      false
    end
    
    def before_create
      self.sent = false if self.sent.nil?
      true
    end
end
