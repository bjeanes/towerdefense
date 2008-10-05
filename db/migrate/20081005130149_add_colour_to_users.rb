class AddColourToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :colour, :string
  end

  def self.down
    remove_column :users, :colour
  end
end
