class ExternalBook < ActiveRecord::Base
  def self.locate_book(code)
    raise "nyi"
  end

  def path_to_files
    self.files_path || self.code
  end
end
