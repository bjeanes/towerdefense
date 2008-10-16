class Message < ActiveRecord::Base
  belongs_to :sender, :class_name => "User"
  belongs_to :recipient, :class_name => "User"
  
  validates_presence_of :sender_id
  validates_presence_of :recipient_id, :if => :recipient_required?
  
  validates_presence_of :content
  
  validates_presence_of :channel_id, :if => :channel_required?
  
  # the order should be reversed for logical display in view for history
  named_scope :history, :limit => 5, :order => 'created_at DESC'
  
  named_scope :for_lobby, :conditions => {:kind => 'lobby', :recipient_id => nil}

  for_channel_block = lambda { |channel| 
    raise "Missing game object for message finder" if channel.nil?
    {
      :conditions => {
      :kind => 'channel', 
      :channel_id => channel.id, 
      :recipient_id => nil}
    }
  }

  named_scope :for_channel, for_channel_block
    
  
  def channel
    return kind if kind == 'lobby'
    
    channel_id
  end
  
  def timestamp
    created_at.strftime("%d %b %y @ %H:%M")
  end
  
  def sent!
    sent = true
    save!
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
