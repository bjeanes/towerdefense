class AddCurrentGameIdToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :current_game_id, :integer, :default => nil
  end

  def self.down
    remove_column :users, :current_game_id
  end
end
