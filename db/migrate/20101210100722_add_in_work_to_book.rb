class AddInWorkToBook < ActiveRecord::Migration
  def self.up
    add_column :books, :in_work, :boolean
  end

  def self.down
    remove_column :books, :in_work
  end
end
