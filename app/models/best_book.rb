class BestBook < ExternalBook
  establish_connection :best
  set_table_name :books

  has_many :formats, :class_name => "BestFormat", :foreign_key => :book_id

  serialize :add_info

  def self.locate_book(code)
    self.find_by_uniq_code(code)
  end

  def files_path
    self.uniq_code || self.code
  end
end
