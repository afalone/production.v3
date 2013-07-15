class AddPresetToProduction < ActiveRecord::Migration
  def self.up
    add_column :productions, :preset_id, :integer, :null => false
    add_index :productions, :preset_id
  end

  def self.down
    remove_column :productions, :preset_id
  end
end
