class AddAbbyyP2fFlagsToPage < ActiveRecord::Migration
  def self.up
    add_column :pages, :doc_ready, :boolean, :null => false, :default => false
    add_column :pages, :text_ready, :boolean, :null => false, :default => false
    add_column :pages, :view_ready, :boolean, :null => false, :default => false
    add_column :pages, :quote_ready, :boolean, :null => false, :default => false
  end

  def self.down
    remove_column :pages, :doc_ready
    remove_column :pages, :text_ready
    remove_column :pages, :view_ready
    remove_column :pages, :quote_ready
  end
end
