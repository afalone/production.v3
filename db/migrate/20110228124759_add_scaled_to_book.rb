class AddScaledToBook < ActiveRecord::Migration
  def self.up
    add_column :books, :scaled, :boolean
  end

  def self.down
    remove_column :books, :scaled
  end
end
