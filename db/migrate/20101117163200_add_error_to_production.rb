class AddErrorToProduction < ActiveRecord::Migration
  def self.up
    add_column :productions, :error_message, :text
    add_column :productions, :last_error_at, :timestamp
  end

  def self.down
    remove_column :productions, :error_message
    remove_column :productions, :last_error_at
  end
end
