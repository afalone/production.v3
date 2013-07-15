class AddStalledCountToProduction < ActiveRecord::Migration
  def self.up
    add_column :productions, :stalled_count, :integer
  end

  def self.down
    remove_column :productions, :stalled_count
  end
end
