class AddPreviewFieldsToPages < ActiveRecord::Migration
  def self.up
    add_column :pages, :preview_ready, :boolean, :default => false
    add_column :pages, :preview_ready_time, :datetime
    add_column :pages, :preview_updated_at, :datetime
    add_column :books, :preview_pages_count, :integer
  end

  def self.down
    remove_column :pages, :preview_ready
    remove_column :pages, :preview_ready_time
    remove_column :pages, :preview_updated_at
    remove_column :books, :preview_pages_count
  end
end
