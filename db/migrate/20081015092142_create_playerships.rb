class CreatePlayerships < ActiveRecord::Migration
  def self.up
    create_table :playerships do |t|
      t.integer :game_id
      t.integer :player_id
      t.boolean :owner
      t.integer :money
      t.integer :lives

      t.timestamps
    end
  end

  def self.down
    drop_table :playerships
  end
end
