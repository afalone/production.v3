class AddBookIdToPages < ActiveRecord::Migration
  def self.up
    add_column :pages, :book_id, :integer, :null=>false
    add_index :pages, :book_id
  end

  def self.down
    remove_column :pages, :book_id
  end
end
