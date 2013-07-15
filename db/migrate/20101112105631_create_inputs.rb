class CreateInputs < ActiveRecord::Migration
  def self.up
    create_table :inputs do |t|
        t.string :name, :null=>false
        t.string :source_path, :null=>false
        t.string :class_prefix
        t.integer :preset_id
        t.integer :output_id
        t.timestamps
    end
    create_table :inputs_productions, :id=>false do |t|
      t.integer :input_id
      t.integer :production_id
    end
    add_index :inputs_productions, :input_id
    add_index :inputs_productions, :production_id
    add_index :inputs, :preset_id
    add_index :inputs, :output_id

  end

  def self.down
    drop_table :inputs_productions
    drop_table :inputs
  end
end
