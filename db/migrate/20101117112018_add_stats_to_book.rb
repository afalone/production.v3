class AddStatsToBook < ActiveRecord::Migration
  def self.up
    add_column :books, :pdf_md5, :string
    add_column :books, :pdf_filesize, :integer
    add_column :books, :pdf_filename, :string
    add_column :books, :pdf_avg_page_filesize, :integer
    add_column :books, :pdf_avg_page_width, :integer
    add_column :books, :pdf_avg_page_height, :integer
  end

  def self.down
    remove_column :books, :pdf_md5
    remove_column :books, :pdf_filesize
    remove_column :books, :pdf_filename
    remove_column :books, :pdf_avg_page_filesize
    remove_column :books, :pdf_avg_page_height
    remove_column :books, :pdf_avg_page_width
  end
end
