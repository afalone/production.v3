class AddOutputsToProduction < ActiveRecord::Migration
  def self.up
    create_table :outputs_productions, :id=>false do |t|
      t.integer :output_id, :null => false
      t.integer :production_id, :null => false
    end
    add_index :outputs_productions, :output_id
    add_index :outputs_productions, :production_id
  end

  def self.down
    drop_table :outputs_productions
  end
end
