class Message < ActiveRecord::Base
  belongs_to :sender, :class_name => "User"
  belongs_to :recipient, :class_name => "User"
  
  validates_presence_of :sender_id, :content, :channel_id
  
  # the order should be reversed for logical display in view for history
  named_scope :history, :limit => 5, :order => 'created_at DESC'
  
  named_scope :for_lobby, :conditions => {:channel_id => 0, :recipient_id => nil}

  for_channel_block = lambda { |channel| 
    raise "Missing game object for message finder" if channel.nil?
    {
      :conditions => {
      :channel_id => channel.id, 
      :recipient_id => nil}
    }
  }

  named_scope :for_channel, for_channel_block

  def lobby?
    channel_id.zero?
  end

  def sent!
    sent = true
    save!
  end
  
  protected    
    def before_create
      self.sent = false if self.sent.nil?
      true
    end
end
