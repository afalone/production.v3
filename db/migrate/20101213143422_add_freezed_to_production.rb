class AddFreezedToProduction < ActiveRecord::Migration
  def self.up
    add_column :productions, :freezed, :boolean, :default => false
  end

  def self.down
    remove_column :productions, :freezed
  end
end
