class KnigafundBook < ExternalBook
  establish_connection :kf
  set_table_name :books

  has_many :pages, :class_name => 'KnigafundPage', :foreign_key => :book_id

  def self.locate_book(code)
    self.find_by_code(code)
  end

  def path_to_files
    File.join(self.hash_directory, (self.files_path || self.code))
  end

  def create_pages(pages_list)
    if self.status and (self.status == 'published' or self.status == 'confirmed')
      self.status = 'republishing'
      self.publish_prepared=false
      self.files_ready=false
      self.state=0
    end
    self.pages.destroy_all
    pages_list.each do |page|
      pages.create(:number=>page, :physical_number=>page)
    end
    puts "#{pages_list.length}"
    self.pages_count = (pages_list.empty? ? 0 : pages_list.length)
    self.copy_limit = (pages_list.length > 9 ? ( pages_list.length / 10 ) : 0)
    self.files_ready=true
    self.indexed = false
    self.save
  end


end
