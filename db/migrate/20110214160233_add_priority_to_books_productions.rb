class AddPriorityToBooksProductions < ActiveRecord::Migration
  def self.up
    add_column :books, :priority, :integer, :default => 0
    add_column :productions, :priority, :integer, :default => 0
  end

  def self.down
    remove_column :books, :priority
    remove_column :productions, :priority
  end
end
