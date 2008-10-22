class AddActiveToPlayerships < ActiveRecord::Migration
  def self.up
    add_column :playerships, :active, :boolean
  end

  def self.down
    remove_column :playerships, :active
  end
end
