class CreateReports < ActiveRecord::Migration
  def self.up
    create_table :reports do |t|
      t.string :type
      t.text :message
      t.text :backtrace
      t.string :source
      t.boolean :processed, :default => false

      t.timestamps
    end
  end

  def self.down
    drop_table :reports
  end
end
