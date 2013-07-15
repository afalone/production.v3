class CreateStorages < ActiveRecord::Migration
  def self.up
    create_table :storages do |t|
      t.string :name
      t.string :prefix
      t.integer :output_id
      t.boolean :active, :default => false
      t.timestamps
    end
    add_index :storages, :output_id
  end

  def self.down
    drop_table :storages
  end
end
