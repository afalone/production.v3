class AddPageAndBookStatFields < ActiveRecord::Migration
  def self.up
    add_column :pages, :text_ready_time, :timestamp
    add_column :pages, :text_updated_at, :timestamp
    add_column :pages, :doc_ready_time, :timestamp
    add_column :pages, :doc_updated_at, :timestamp
    add_column :pages, :view_ready_time, :timestamp
    add_column :pages, :view_updated_at, :timestamp
    add_column :pages, :quote_ready_time, :timestamp
    add_column :pages, :quote_updated_at, :timestamp
    add_column :pages, :view_created_on_retry, :integer
    add_column :pages, :quote_created_on_retry, :integer
    add_column :pages, :exception, :boolean, :default => false
    add_column :pages, :exception_at, :timestamp
    add_column :pages, :manually_preparable, :boolean, :default => false
    add_column :productions, :current_retry, :integer
    add_column :books, :doc_pages_count, :integer
    add_column :books, :text_pages_count, :integer
    add_column :books, :view_pages_count, :integer
    add_column :books, :quote_pages_count, :integer
    add_column :productions, :with_verification, :boolean
  end

  def self.down
    remove_columns :pages, :text_ready_time, :text_updated_at, :doc_ready_time, :doc_updated_at,
                  :view_ready_time, :view_updated_at, :quote_ready_time, :quote_updated_at,
                  :view_created_on_retry, :quote_created_on_retry, :exception, :exception_at,
                  :manually_preparable
    remove_columns :productions, :current_retry, :with_verification
    remove_columns :books, :doc_pages_count, :text_pages_count, :view_pages_count, :quote_pages_count
  end
end
