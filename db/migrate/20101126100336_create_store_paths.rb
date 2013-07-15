class CreateStorePaths < ActiveRecord::Migration
  def self.up
    create_table :store_paths do |t|
      t.string :hash_directory
      t.integer :storage_id, :null => false
      t.boolean :active, :default => false
      t.timestamps
    end
    add_index :store_paths, :storage_id
  end

  def self.down
    drop_table :store_paths
  end
end
