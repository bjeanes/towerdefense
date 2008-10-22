class RemoveKindFromMessages < ActiveRecord::Migration
  def self.up
    remove_column :messages, :kind
  end

  def self.down
    add_column :messages, :kind, :string
  end
end
