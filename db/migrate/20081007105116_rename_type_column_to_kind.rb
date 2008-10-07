class RenameTypeColumnToKind < ActiveRecord::Migration
  def self.up
    rename_column :messages, :type, :kind
  end

  def self.down
    rename_column :messages, :kind, :type
  end
end
