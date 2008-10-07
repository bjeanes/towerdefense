class Message < ActiveRecord::Base
  belongs_to :sender, :class_name => "User"
  belongs_to :recipient, :class_name => "User"
  
  validates_presence_of :sender_id
  validates_presence_of :recipient_id, :if => :recipient_required?
  
  validates_presence_of :content
  
  validates_presence_of :channel_id, :if => :channel_required?
  
  named_scope :lobby, :conditions => {:kind => 'lobby', :recipient_id => nil}, :order => 'created_at desc'
  
  def channel
    return kind if kind == 'lobby'
    
    channel_id
  end
  
  def timestamp
    created_at.strftime("%H:%M")
  end
  
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
