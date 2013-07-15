class Book < ActiveRecord::Base
  validates_format_of :name, :with=>/^(ISBN|DDCC)-[0123456789\-]+[0123456789X]$/uim
  validates_uniqueness_of :name

  has_many :pages
  has_many :productions

  def self.register(book_name)
    #создает или находит книгу и возвращает ее. при ошибках вернуть nil
    book = self.find_or_create_by_name(book_name) #todo params
    book
  end

  def work_catalog
    File.join(WORK_BOOKS_PATH, name)
  end

  def pdf_work_path
    File.join(work_catalog, pdf_filename||"#{name}.pdf")
  end

  def abbyy_input_catalog
    File.join(ABBYY_INPUT_AUTO, name)
  end

  def abbyy_exception_catalog
    File.join(ABBYY_EXCEPTIONS_AUTO, name)
  end

  def abbyy_out_catalog
    File.join(ABBYY_OUTPUT_AUTO, name)
  end

  def get_page_by_file_name(fname)
    nm = fname[4, 4].to_i
    self.pages.find_by_page_no(nm)
  end

  def possible_backup_catalogs
    %w(/mnt/work /mnt/work/2009 /mnt/backup/books) + ["/mnt/backup/books/#{created_at.month.to_s.rjust(2, '0')}"]
  end

  def backup_catalogs
    (possible_backup_catalogs()).map{|p| File.join p, self.name }.select{|p| File.directory? p }
  end

  def restart_book
    self.productions.where(:need_restart => true).each{|p| p.restart_production! }
  end

  #to module backups
  def move_files_to_backup
    update_attributes :locked_at => Time.now
    back_cat = File.join("/mnt/backup/books", created_at.month.to_s.rjust(2, '0'))
    unless File.directory?(back_cat)
      Dir.mkdir(back_cat)
    end
    back_path = File.join(back_cat, name)
    unless File.directory?(back_path)
      FileUtils.rm_f(back_path) if File.exist?(back_path)
      Dir.mkdir(back_path)
    end
    #есть архив, есть пдф, есть сгенеренные пдф/пдц, есть обложки и превью
    flist = []
    flist << "#{name}.pdf" if File.exist?(File.join(work_catalog, "#{name}.pdf"))
    flist << "#{name}.png" if File.exist?(File.join(work_catalog, "#{name}.png"))
    flist << "#{name}.jpg" if File.exist?(File.join(work_catalog, "#{name}.jpg"))
    flist << "#{name}_w.pdf" if File.exist?(File.join(work_catalog, "#{name}_w.pdf"))
    flist << "#{name}.pdc" if File.exist?(File.join(work_catalog, "#{name}.pdc"))
    flist << "#{name}.rar" if File.exist?(File.join(work_catalog, "#{name}.rar"))
    Dir[File.join(work_catalog, "#{name}_test*.jpg")].each{|n| flist << File.basename(n) }
#    flist << "#{name}.pdf" if File.exist?(File.join(work_catalog, "#{name}.pdf"))
    flist.each do |file|
      FileUtils.rm_f File.join(back_path, file)
      FileUtils.cp File.join(work_catalog, file), back_path, :verbose => true
    end
    update_attributes :locked_at => nil, :in_work => false
    FileUtils.rm_r work_catalog
    puts "done #{name}:#{id}"
  end

  def clear_old_backups

  end

  def recover_from_backup

  end
end
