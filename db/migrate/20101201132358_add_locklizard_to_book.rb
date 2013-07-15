class AddLocklizardToBook < ActiveRecord::Migration
  def self.up
    add_column :books, :locklizard_docid, :integer
  end

  def self.down
    remove_column :books, :locklizard_docid
  end
end
