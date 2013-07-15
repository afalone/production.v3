class AddOutputToPreset < ActiveRecord::Migration
  def self.up
    add_column :presets, :output_id, :integer

    add_index :presets, :output_id
  end

  def self.down
    remove_column :presets, :output_id
  end
end
