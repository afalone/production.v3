class StorePath < ActiveRecord::Base
  belongs_to :storage

  def full_path
    File.join(self.prefix, self.hash_directory)
  end

  def prefix
    self.storage.prefix
  end

  def ready?
    self.active? and self.storage.avail?
  end

  def contain_book?(ext_book)
    ext_book.hash_directory == self.hash_directory
  end
end
