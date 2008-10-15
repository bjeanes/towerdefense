class CreateGames < ActiveRecord::Migration
  def self.up
    create_table :games do |t|
      t.datetime :started_at
      t.datetime :completed_at
      t.string :name

      t.timestamps
    end
  end

  def self.down
    drop_table :games
  end
end
