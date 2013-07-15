class CreatePresets < ActiveRecord::Migration
  def self.up
    create_table :presets do |t|
      t.string :name
      t.integer :view_before_printing_timeout
      t.integer :view_printing_timeout
      t.integer :view_after_printing_timeout
      t.boolean :view_kill_process_if_timeout
      t.integer :quote_before_printing_timeout
      t.integer :quote_printing_timeout
      t.integer :quote_after_printing_timeout
      t.boolean :quote_kill_process_if_timeout
      t.boolean :require_view_printing, :default => true, :null => false
      t.boolean :require_quote_printing, :default => true, :null => false
      t.string :license_text
      t.timestamps
    end

  end

  def self.down
    drop_table :presets
  end
end
