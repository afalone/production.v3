class AddIsActiveToInput < ActiveRecord::Migration
  def self.up
    add_column :inputs, :is_active, :boolean, :default => false, :null => false
  end

  def self.down
    remove_column :inputs, :is_active
  end
end
