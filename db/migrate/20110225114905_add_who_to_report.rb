class AddWhoToReport < ActiveRecord::Migration
  def self.up
    add_column :reports, :who, :string
  end

  def self.down
    remove_column :reports, :who
  end
end
