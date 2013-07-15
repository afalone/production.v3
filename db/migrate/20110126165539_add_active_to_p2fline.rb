class AddActiveToP2fline < ActiveRecord::Migration
  def self.up
    add_column :p2flines, :active, :boolean, :default => false
    P2fline.update_all "active = 'f'"
  end

  def self.down
    remove_column :p2flines, :active
  end
end
