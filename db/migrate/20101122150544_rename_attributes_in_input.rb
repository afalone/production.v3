class RenameAttributesInInput < ActiveRecord::Migration
  def self.up
    add_column :inputs, :default_preset_name, :string
    add_column :inputs, :default_output_name, :string
#    remove_column :inputs, :default_print_profile_name
#    remove_column :inputs, :default_publish_profile_name
  end

  def self.down
#    add_column :inputs, :default_print_profile_name, :string
#    add_column :inputs, :default_publish_profile_name, :string
    remove_column :inputs, :default_preset_name
    remove_column :inputs, :default_output_name
  end
end
