class Game < ActiveRecord::Base
  has_one  :owner, :class_name => "User", :foreign_key => "user_id"
  has_many :users
end
