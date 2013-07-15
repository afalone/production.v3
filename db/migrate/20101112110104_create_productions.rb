class CreateProductions < ActiveRecord::Migration
  def self.up
    create_table :productions do |t|
      t.string :type
      t.string :state
      t.integer :book_id, :null=>false
      t.integer :input_id
      t.timestamps
    end
  end

  def self.down
    drop_table :productions
  end
end
