class AddIncomeToPlayerships < ActiveRecord::Migration
  def self.up
    add_column :playerships, :income, :integer, :default => 0
  end

  def self.down
    remove_column :playerships, :income
  end
end
