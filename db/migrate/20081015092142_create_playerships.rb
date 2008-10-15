class CreatePlayerships < ActiveRecord::Migration
  def self.up
    create_table :playerships do |t|
      t.integer :game_id,   :null => false
      t.integer :player_id, :null => false
      t.boolean :owner,     :default => false
      t.integer :money,     :default => 0
      t.integer :lives,     :default => 0

      t.timestamps
    end
  end

  def self.down
    drop_table :playerships
  end
end
