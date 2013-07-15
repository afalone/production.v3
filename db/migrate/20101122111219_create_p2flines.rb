class CreateP2flines < ActiveRecord::Migration
  def self.up
    create_table :p2flines do |t|
      t.string :name, :null=>false
      t.boolean :can_view, :null=>false, :default=>true
      t.boolean :can_quote, :null=>false, :default=>true
      t.integer :print_pid
      t.integer :production_id
      t.timestamps
    end
    add_index :p2flines, :production_id
  end

  def self.down
    drop_table :p2flines
  end
end
