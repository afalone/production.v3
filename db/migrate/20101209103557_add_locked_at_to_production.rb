class AddLockedAtToProduction < ActiveRecord::Migration
  def self.up
    add_column :books, :locked_at, :datetime
  end

  def self.down
    remove_column :books, :locked_at
  end
end
