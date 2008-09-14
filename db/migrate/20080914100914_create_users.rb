class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :username
      t.string :session_id
      t.datetime :last_active_at

      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end
