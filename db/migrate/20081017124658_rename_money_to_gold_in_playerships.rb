class RenameMoneyToGoldInPlayerships < ActiveRecord::Migration
  def self.up
    rename_column :playerships, :money, :gold
  end

  def self.down
    rename_column :playerships, :gold, :money
  end
end
