class Production < ActiveRecord::Base
  #todo backup work catalog, with check -- all productions must be published
  # предварительно - скан по книгам, выкеинуть рабочие или сбэкапленные.
  # вытаскивание файлов из бакапа ставит флаг грязности
  belongs_to :book
  belongs_to :input
  belongs_to :preset

  validates_presence_of :book
  validates_presence_of :input
  validates_uniqueness_of :type, :scope => :book_id

  scope :typed, lambda{|prodtype|
    types = {"working" => %w(in_abbyy p2f_queue p2f_line p2f_printing p2f_printed pdc_feeded pdc_processed pdc_scaned pdc_ready pdf_preparing pdf_ready preview_prepared cover_prepared text_extracting text_extracted restarting flex_queue),
             "confirm" => %w(confirmation_waiting),
             "loaded" => %w(created started scaling loaded),
             "publishing" => %w(confirmed publish_preparing uploading publishing),
             "published" => %w(published) }
    where(:state => types[prodtype]) if types[prodtype]
  }

  state_machine :state, :initial => :created do
    event :start_created do
      transition :created => :started, :if => :prepared_in_work?
    end
    after_transition :created => :started, :do => :exec_production


    event :to_scaling do
      transition :started => :started, :if => :split_required?
      transition :started => :scaling, :if => :splitted?
      transition :started => :p2f_printed
    end
    before_transition :started => :started, :do => :prepare_to_load

    event :to_loaded do
      transition :scaling => :scaling, :if => :need_scale?
      transition :scaling => :loaded, :if => :scaled_for_abbyy?
      transition :scaling => :p2f_queue, :if => :scaled_for_p2f?
      transition :scaling => :p2f_printed, :if => :scaled? # fixme chg dest fo p2f_queue for non-abbyy?
      #transition :scaling => :p2f_printed
    end
    before_transition :scaling => :scaling, :do => :scale_pages
    before_transition :scaling => :loaded, :do => :load_production

    event :to_abbyy do
      transition :loaded => :in_abbyy, :if => :abbyy_required?
      transition :loaded => :p2f_queue
    end
    before_transition :loaded => :in_abbyy, :do => :feed_abbyy

    event :from_abbyy do
      transition :in_abbyy => :in_abbyy, :unless => :abbyy_ready?
      transition :in_abbyy => :failed, :if => :abbyy_exception?
      transition :in_abbyy => :p2f_queue
    end
    before_transition :in_abbyy => [:in_abbyy, :p2f_queue], :do => :take_abbyy_printed

    event :to_p2fline do
      transition :p2f_queue => :p2f_line, :if => :p2f_allowed? #in allowed - set line when its avail
      transition :p2f_queue => :p2f_printed, :unless => :p2f_required?
      transition :p2f_queue => :p2f_queue
    end
    before_transition :p2f_queue => :p2f_line, :do => :p2f_prepare_working_copy

    event :start_p2f do
      transition :p2f_line => :p2f_printing
    end
    before_transition :p2f_line => :p2f_printing, :do => :p2f_select_and_block_line

    event :done_p2f do
      transition :p2f_printing => :p2f_printed
    end

    event :to_flex do
      transition :p2f_printed => :flex_queue, :if => :flex_allowed?
      transition :p2f_printed => :flex_printed
    end

    event :to_flexline do
      transition :flex_queue => :flex_line, :if => :flex_allowed? #in allowed - set line when its avail
      transition :flex_queue => :flex_printed, :unless => :flex_required?
      transition :flex_queue => :flex_queue
    end
    before_transition :flex_queue => :flex_line, :do => :p2f_prepare_working_copy

    event :start_flex do
      transition :flex_line => :flex_printing
    end
    #before_transition :p2f_line => :p2f_printing, :do => :p2f_select_and_block_line

    event :done_flex do
      transition :flex_printing => :flex_printed
    end

    #todo flex methods
    event :to_locklizard do
      transition :flex_printed => :pdc_feeded, :if => :pdc_required?
      transition :flex_printed => :pdc_ready
    end
    before_transition :flex_printed => :pdc_feeded, :do => :mk_pdc_working_copy

    event :locklizard_print do #only win llz
      transition :pdc_feeded => :pdc_processed
    end
    before_transition :pdc_feeded => :pdc_processed, :do => :generate_pdc

    event :scan_pdc do
      transition :pdc_processed => :pdc_scaned
    end
    before_transition :pdc_processed => :pdc_scaned, :do => :scan_locklizard_id

    event :done_pdc do
      transition :pdc_scaned => :pdc_ready
    end
    before_transition :pdc_scaned => :pdc_ready, :do => :pdc_clean_work

    event :process_pdf do
      transition :pdc_ready => :pdf_preparing, :if => :pdf_required?
      transition :pdc_ready => :pdf_ready
    end
    before_transition :pdc_ready => :pdf_preparing, :do => :build_exposable_pdf

    event :done_pdf do
      transition :pdf_preparing => :pdf_ready, :if => :pdf_checked?
    end

    event :process_preview do
      transition :pdf_ready => :preview_prepared
    end
    before_transition :pdf_ready => :preview_prepared, :do => :prepare_preview

    event :process_cover do
      transition :preview_prepared => :cover_prepared
    end
    before_transition :preview_prepared => :cover_prepared, :do => :prepare_cover

    event :textprocess_start do
      transition :cover_prepared => :text_extracting, :if => :textextract_required?
      transition :cover_prepared => :text_extracted
    end
    before_transition :cover_prepared => :text_extracting, :do => :text_extract
    #event :text_extract

    event :textprocess_done do
      transition :text_extracting => :text_extracted
    end

    event :done_printing do   #place for new states
      transition :text_extracted => :confirmation_waiting
    end

    event :confirm do
      transition :confirmation_waiting => :confirmed
    end
    after_transition :confirmation_waiting => :confirmed, :do => :ping_publication

    event :to_publish_queue do
      transition :confirmed =>:publish_preparing
    end

    event :start_publication do
      transition :publish_preparing => :uploading
    end
    before_transition :publish_preparing => :uploading, :do => :prepare_for_upload #compress, ага

    event :process_upload do
      transition :uploading => :publishing
    end
    before_transition :uploading => :publishing, :do => :upload_files

    event :done_publish do
      transition :publishing => :published
    end
    before_transition :publishing => :published, :do => :process_on_server
    after_transition :publishing => :published, :do => :try_backup

    event :to_hold do
      transition any - [:hold] => :hold
    end

    event :restart_production do
      transition any - [:restarting] => :restarting
    end
    before_transition any - [:restarting] => :restarting, :do => :init_restart

    event :do_restart do
      transition :restarting => :created, :if => :required_full_restart?
      transition :restarting => :p2f_queue, :if => :required_partial_restart?
      transition :restarting => :uploading, :if => :allowed_republish?
    end
    before_transition :restarting => :created, :do => :process_full_restart
    before_transition :restarting => :p2f_queue, :do => :process_partial_restart
    after_transition :restarting => any - [:restarting], :do => :post_restart

    state :created #создана. больше ничего
    state :started #подготовлена (есть work_catalog, исходники в нем)
    state :scaling
    state :loaded #подготовлено всё абби, п2ф (порезана, страницы обработаны)
    state :in_abbyy
    state :p2f_queue
    state :p2f_line
    state :p2f_printing
    state :p2f_printed #p2f swf ended
    state :flex_queue
    state :flex_line
    state :flex_printing
    state :flex_printed
    state :pdc_feeded  #in working copy
    state :pdc_processed #locklizarded
    state :pdc_scaned #id extracted
    state :pdc_ready #pdc done or unneeded
    state :pdf_preparing
    state :pdf_ready #pdf done or unneeded
    state :preview_prepared
    state :cover_prepared
    state :text_extracting
    state :text_extracted
    state :failed
    state :confirmation_waiting
    state :confirmed
    state :publish_preparing #compress or any
    state :uploading
    state :publishing #run on server
    state :published
    state :restarting
    state :hold
  end
  #em workers
  def prepare_to_load
    cmd = "cd #{work_catalog};pdftk #{book.pdf_work_path} burst output #{File.join(work_catalog, "page%04d.pdf")}"
    puts cmd
    IO.popen(cmd)
    Process.wait
    Page.scan_path(self)
    avg = self.scan_averages
    #todo check for avg file size
    unless book.pdf_filesize
      book.update_attributes :pdf_filesize => File.stat(book.pdf_work_path).size
    end
    book.update_attributes :pages_count => avg[:count], :pdf_avg_page_filesize => avg[:avg_size],
                           :pdf_avg_page_width => avg[:width], :pdf_avg_page_height => avg[:height]
    if avg.has_key?(:avg_size) and avg[:avg_size] > 1.megabyte and avg[:avg_size] > (book.pdf_filesize || File.stat(book.pdf_work_path).size )/2
      self.update_attributes(:error_message => "pdf file broken")
      #todo hold errorable self.to_hold!
      FileUtils.rm Dir.glob(File.join(work_catalog, "page*.pdf"))
    end
    self.book.update_attributes(:locked_at => nil)
  end

  def load_production
    Page.scan_path(self)
  end

  def feed_abbyy
    #todo chk exceptions
    abbyy_tmp = File.join(ABBYY_TMP, book.name)
    FileUtils.rm_rf(abbyy_tmp) if File.directory? abbyy_tmp
    FileUtils.rm_rf book.abbyy_exception_catalog if File.exists? book.abbyy_exception_catalog
    Dir.mkdir abbyy_tmp
    Dir[File.join(work_catalog, "page*.pdf")].sort.each do |page_path|
      page = book.get_page_by_file_name(File.basename(page_path))    #!
      next unless page
      FileUtils.copy page_path, abbyy_tmp unless (page.doc_ready? and page.text_ready?) #!
      page.update_attributes :exception=>:false, :retry_exception=>false if page.exception? # or page.retry_exception? #!
    end
    FileUtils.rm_rf book.abbyy_input_catalog if File.exists? book.abbyy_input_catalog
    FileUtils.mv abbyy_tmp, ABBYY_INPUT_AUTO, :verbose=>true if File.directory? abbyy_tmp
    #todo return when manual queue be done FileUtils.mv abbyy_tmp, (self.with_verification? ? ABBYY_INPUT_VERIFY_DIR : ABBYY_INPUT_DIR), :verbose=>true if File.directory? abbyy_tmp

#    self.pages.abbyy_exception.update_all "exception = 'f'"
#    self.apply_pages_count
  end
  #em guards
  def abbyy_required? #refactor
    return false if book.pages.abbyy_non_ready.count == 0
    true
  end

  def split_needed?
    true # pdf должен быть порезан
  end

  def split_required?
    return false unless split_needed?
    if book.pages_count.blank? or book.pages_count <= 0 or book.pages_count != book.pages.count
      puts "empty pages_count"
      return true
    end
    return false unless File.exists?(book.pdf_work_path)
    begin
      calculated_pages = PDF::Toolkit.open(book.pdf_work_path).pages
      pages_found = Dir[File.join(work_catalog, "page????.pdf")].size
      if calculated_pages != pages_found
        #TODO check for manual pages
        puts "found #{pages_found}, but expect to found #{calculated_pages}"
        #todo send to restart or other repager self.full_restart_production!
        return true
      end
    rescue
      puts "error counting pages, bad pdf"
      self.update_attribute :error_message, "error counting pages, bad pdf"
      #todo hold on error self.to_hold!
      return true
    end

    false
  end

  def splitted?
    split_needed? and !split_required?
  end
  #eo em
  def prepare_images_for_check_sizes
    w = h = 0
    begin
      pathname = File.join("/tmp", "#{book.name}_images")
      FileUtils.rm_rf pathname if File.exist? pathname
      Dir.mkdir pathname
      `pdfimages -j #{book.pdf_work_path} #{pathname}/scan`
      Dir["#{pathname}/scan*"].sort.each do |nm|
        str = `identify #{nm}`
        str.scan(/\s(\d+)x(\d+)\s/) do |width, height|
          w += width.to_f
          h += height.to_f
        end
      end
    ensure
      FileUtils.rm_rf pathname
    end
    return w, h
  end

  #helpers #todo to module
  def calc_linear_pages_sizes(count)
    w, h = prepare_images_for_check_sizes
    {:width => w/count, :height => h/count}
  end

  def scan_averages
    files = Dir[File.join(work_catalog, "page????.pdf")]
    pages_count = files.size
    pages_size = files.inject(0){|rez, fname| rez + File.stat(fname).size }
    calc_linear_pages_sizes(pages_count).merge({:count=>pages_count, :avg_size=>pages_size/pages_count})
  end

  def self.find_or_register(input, fname)
    nm = File.basename(fname, '.pdf')
    book = Book.register(nm)
    prod = self.find_by_book_id(book.id)
    return prod if prod #duplicate
    self.register(input, fname)
  end

  def self.register(input, fname) #returns false on nonregistered,
    # (заполнить errors?)
    nm = File.basename(fname, '.pdf')
    book = Book.register(nm)
    production = self.create(:book_id=>book.id, :input_id=>input.id, :preset_id=>input.preset.id)
    #todo add checks?
    production
  end

  def work_catalog
    book.work_catalog
  end

  def working_copy
    File.join work_catalog, WORKING_COPY_SUFFIX
  end

  def update_abbyy_page_state #todo to scan method
    Page.scan_path(self)
    #book.pages.abbyy_non_ready.find_each(:batch_size=>10) { |page| page.update_abbyy }
  end

  def scaled?
    book.scaled? or !need_scale?
  end

  def scaled_for_abbyy?
    (book.scaled? or !need_scale?) and abbyy_required?
  end

  def scaled_for_p2f?
    (book.scaled? or !need_scale?) and (!abbyy_required? and p2f_required?)
  end

  def need_scale?
    return false if book.scaled?
    return false unless book.pdf_avg_page_height? and book.pdf_avg_page_width?
    return false if book.pdf_avg_page_width > book.pdf_avg_page_height
    book.pdf_avg_page_width > 590 or book.pdf_avg_page_height > 830 #its a kind of magick. вынести цифры в пресеты
  end

  def scale_pages
    book.pages.order("page_no DESC").each{|p| p.scale_page_to_a4 }
    book.update_attributes(:scaled => true)
  end

  def pdf_required?
    false
  end

  def pdc_required?
    false
  end

  def pdf_checked?
    File.exist?(self.book.pdf_work_path)
  end

  def prepare_preview #refactor later. ugly
    return unless self.preview_required?
    pdf_file_path = book.pdf_work_path
    puts "#{book.name}"
    max_pages = 5
    return false unless File.readable? pdf_file_path
    begin
      max_pages = [5, (PDF::Toolkit.open(pdf_file_path).pages).to_i/10].min
    rescue
      puts "Error running pdf toolkit on book #{book.id} #{book.name} #{self.id}"
      max_pages = 5 #FIXME количество превью в макс - для генерации страниц, не обращая внимания на ошибки тулкита
    end
    puts "pages_count #{max_pages}"
    max_pages.to_i.times do |i|
      page_name = File.join(File.dirname(pdf_file_path), "#{book.name}_test#{(i+1).to_s.rjust(4, '0')}.jpg")
      `convert -quality 80 -colorspace YCbCr -interpolate bicubic -density "300x300" '#{pdf_file_path}[#{i}]' -density "120x120" -geometry 460x660  '#{page_name}'`
    end
  end

  def preview_required?
    false
  end

  def prepare_cover
    return unless cover_required?
    fn = book.pdf_work_path
    return unless fn
    oname = "#{File.join(File.dirname(fn), File.basename(fn, '.pdf'))}.png"
    if File.readable? fn
      cmd = "convert #{fn}[0] #{oname}"
      puts cmd
      IO.popen(cmd)
      Process.wait
    else
      puts "noncreated #{fn} #{oname}"
    end

  end

  def cover_required?
    true
  end

  def textextract_required?
    false
  end

  def ext_book_class
    KnigafundBook
  end

  def pack_files #todo possible to publishing module
    tmp_dir = File.join("/", "tmp", self.book.name)
    puts "copying to tmp dir"
    IO.popen("rm -Rf #{tmp_dir};mkdir #{tmp_dir}")
    Process.wait
    book.pages.each do |page|
      FileUtils.cp "#{page.full_path}.pdf.swf", File.join(tmp_dir, "#{page.file_name}_r.swf") if !watermark_required? and File.exist?("#{page.full_path}.pdf.swf")
      FileUtils.cp "#{page.full_path}_w.pdf.swf", File.join(tmp_dir, "#{page.file_name}_r.swf") if watermark_required? and File.exist?("#{page.full_path}_w.pdf.swf")
      FileUtils.cp "#{page.full_path}.doc.swf", File.join(tmp_dir, "#{page.file_name}.swf") if File.exist?("#{page.full_path}.doc.swf")
      FileUtils.cp "#{page.full_path}.txt", tmp_dir
    end
    FileUtils.cp File.join(work_catalog, 'doc_data.txt'), tmp_dir
    puts "packing"
    IO.popen("cd #{tmp_dir};rar a -y #{book.name}.rar \\*.swf \\*.txt > /dev/null")
    Process.wait
    puts "copying archive back"
    FileUtils.cp_r File.join(tmp_dir, "#{book.name}.rar"), work_catalog, :verbose => true
    puts "remove tmp catalog"
    IO.popen("rm -Rf #{tmp_dir}")
    Process.wait
  end

  def prepare_for_upload
    require 'md5'
    prod_book = self.ext_book_class.locate_book(book.name)
    unless prod_book
      self.update_attribute :error_message, 'book was not created at backoffice2 - upload .xls with descriptive firstly.'
#      Report.add 'PublishError', 'compress', "Book:#{self.name}", "was not created at backoffice2 - upload .xls with descriptive firstly."
#      logger.info 'book was not created at backoffice2 - upload .xls with descriptive firstly.'
      raise "book #{book.name} was not created at backoffice2"
    end
    self.pack_files
#    self.archive_md5 = MD5.new(File.read(self.locate_archive)).hexdigest
#    puts "calculated md5 #{self.archive_md5}"
#    self.update_attributes :archive_md5 => self.archive_md5
#    if self.confirmed?
#      self.do_compress!
#      Report.add 'Publish', 'compress', "Book:#{self.name}", "compressed"
#    else
#      self.do_compress_non_full!
#      Report.add 'Publish', 'compress', "Book:#{self.name}", "partialy compressed"
#    end

  end

  def upload_files
    #up .rar & cover
    self.preset.output.upload_book(self)
  end

  def unpack_book_on_server
    require 'net/ssh'
    begin
      prod_book = ext_book_class.locate_book(book.name)
      hashed_path = preset.output.path_for_book(prod_book)
      if hashed_path
        unless hashed_path.ready?
          puts "nonready path #{hashed_path.hash_directory}, later"
          raise "nonready path #{hashed_path.hash_directory}, later"
        end
      end
      Net::SSH.start(preset.output.server_host, preset.output.server_user, :password => preset.output.server_password) do |ssh|
        puts "Book.unpack_book_on_server::unpack #{book.name}"
        puts "#{preset.output.extract_command} e -y #{File.join(preset.output.upload_basedir, prod_book.path_to_files, book.name)}.rar  #{File.join preset.output.upload_basedir, prod_book.path_to_files}/"
        puts ssh.exec!("#{preset.output.extract_command} e -y #{File.join(preset.output.upload_basedir, prod_book.path_to_files, book.name)}.rar  #{File.join preset.output.upload_basedir, prod_book.path_to_files}/ ")
      end
    rescue Exception => e
      puts "error unpack"
      raise "error processing book #{e}"
    end
  end

  def process_on_server
    unpack_book_on_server
    puts "make pages"
    ext_book_class.locate_book(book.name).create_pages(book.pages.map(&:page_no))
    puts "done pages"
  end

  def prepared_in_work?
    File.directory?(self.work_catalog) and File.exist?(self.book.pdf_work_path)
  end

  def exec_production
    puts "startup #{self.id}"
    book.update_attributes(:scaled => false)
    PdfSplitter.enqueue(self)
  end

  def llz_work_path #for llz win machine only
    File.join(LLZ_WORK_PREFIX, self.book.name, WORKING_COPY_SUFFIX)
  end

  def p2f_work_path #for llz win machine only
    File.join(WORKING_COPY_PREFIX, self.book.name, WORKING_COPY_SUFFIX)
  end

  def create_working_copy_catalog
    unless File.directory?(self.working_copy)
      FileUtils.rm_f(self.working_copy, :verbose => true) if File.exist?(self.working_copy)
      Dir.mkdir self.working_copy
    end
  end

  def mk_pdc_working_copy
    return unless book.locklizard_docid.blank?
    #copy to work cat
    create_working_copy_catalog
    FileUtils.cp self.book.pdf_work_path, self.working_copy, :verbose => true
  end

  def generate_pdc #running in win
    puts "start llz"
    unless book.locklizard_docid.blank?
      p book.locklizard_docid
      puts "locklizarded"
      return
    end
    puts "name"
    iname = File.join(llz_work_path, book.pdf_filename || "#{book.name}.pdf")
    puts iname
    msg = self.preset.license_text
    cmd = "PDCWriter PROTECT \"#{iname.gsub(/\//, "\\")}\" /ACCESS \"outside\" /SPLASH \"d:\\shop.books\\logo.png\" /MORESCREENPROTECTION /NOMACVIEW /NOPROGRESS /ADMESSAGE \"#{Iconv.iconv "WINDOWS-1251", "UTF-8", msg }\" /OUTPUT \"#{llz_work_path.gsub(/\//, "\\")}\""
    puts cmd

    IO.popen(cmd)
    Process.wait
  end

  def scan_locklizard_id
    return unless book.locklizard_docid.blank?
    FileUtils.mv File.join(self.working_copy, "#{self.book.name}.pdc"), self.work_catalog
    l_id = discover_docid(File.join(work_catalog, "#{book.name}.pdc"))
    book.update_attributes(:locklizard_docid => l_id) unless l_id.blank?
  end

  def discover_docid(fname)
    l_id = nil
    File.open(fname, "r") do |f|
      s = f.read(8192)
      s.scan(/Document ID:\s(\d+)\s/) do |id|
        l_id = id[0] if id && id[0]
      end
      if l_id.blank?
        f.rewind
        s=f.read
        s.scan(/Document ID:\s(\d+)\s/) do |id|
          l_id = id[0] if id && id[0]
        end
      end
    end
    l_id
  end

  def pdc_clean_work
    if File.directory?(working_copy)
      FileUtils.rm File.join(working_copy, "#{book.name}.pdf")
      if Dir[File.join(working_copy, '*')].empty?   #todo additional check
        FileUtils.rmdir working_copy
      end
    end
  end

  def abbyy_ready?
    book.pages.abbyy_non_ready.non_exceptioned.count == 0
  end

  def take_abbyy_printed
    if File.exists?(book.abbyy_out_catalog)
      Dir[File.join(book.abbyy_out_catalog, "page*.txt")].each do |name|
        FileUtils.cp name, work_catalog, :verbose=>true
        FileUtils.rm name, :verbose => true
      end
      Dir[File.join(book.abbyy_out_catalog, "page*.doc")].each do |name|
        FileUtils.cp name, work_catalog, :verbose=>true
        FileUtils.rm name, :verbose => true
      end
    end
    update_abbyy_page_state
  end

  def p2f_required?
    true
  end

  def flex_required?
    false
  end

  def p2f_prepare_working_copy
    create_working_copy_catalog
    if watermark_required?
      book.pages.each{|p| p.watermark_page('watermark', File.join(working_copy, "#{p.file_name}_w.pdf")) }
    else
      book.pages.each{|p| p.copy_page(working_copy) }
    end
  end

  def text_extract
    book.pages_count.times do |i|
      `pdftotext -f #{i+1} -l #{i+1} #{book.pdf_work_path} #{File.join(work_catalog, "page#{(i+1).to_s.rjust(4, '0')}.txt")}`
    end
    Page.scan_path(self)

  end
  def watermark_required?
    false
  end

  def p2f_allowed?
    p2f_required? and P2fline.all.detect{|l| l.active? and !(l.can_view? ^ preset.require_view_printing?) and !(l.can_quote? ^ preset.require_quote_printing?)}
  end

  def flex_allowed?
    flex_required? and !p2f_required? #todo более точно определять разрешенность флексы
  end

  def non_ready_pages
    self.book.pages.p2f_non_ready
  end

  def required_suffixes
    %w(.pdf.swf .doc.swf _w.pdf.swf)
  end

  def build_exposable_pdf
  end

  def abbyy_exception?
    not book.pages.abbyy_non_ready.select{|page| page.abbyy_exception? }.empty?
  end

  def stale?
    if (stalled_count || 0) < 5
      self.update_attributes :stalled_count => (stalled_count || 0) + 1
      return true
    end
    false
  end

  def clean_stale
    self.update_attributes :stalled_count => 0
  end

  def p2f_select_and_block_line

  end

  def ping_publication
    PublishIgniter.enqueue(self)
  end

  def required_full_restart?
    self.need_restart? and (self.need_full_restart? or self.source_changed?)
  end

  def required_partial_restart?
    self.need_restart? and !self.required_full_restart?
    #todo chk files
  end

  def allowed_republish?
    not self.need_restart?
  end

  def process_full_restart
    self.reinitialize_production(true) #todo!!!
  end

  def reinitialize_production(full = false)
    self.clean_work_files(full)
    if full
      self.kill_pages
    end

  end

  def kill_pages
    book.pages.each{|page| page.destroy } #todo chg to mass op
  end

  def clean_work_files(full = false) #remove prepared (swf)/(doc/txt/pdf)
    if full
      Dir[File.join(work_catalog, "page*.pdf.swf")].each{|nm| FileUtils.rm nm}
      Dir[File.join(work_catalog, "page*.doc.swf")].each{|nm| FileUtils.rm nm}
      Dir[File.join(work_catalog, "page*.doc")].each{|nm| FileUtils.rm nm }
      Dir[File.join(work_catalog, "page*.txt")].each{|nm| FileUtils.rm nm  }
      Dir[File.join(work_catalog, "page*.pdf")].each{|nm| FileUtils.rm nm  }
    end
  end

  def process_partial_restart
    self.reinitialize_production(false)
                            #todo!!!
  end

  def init_restart
    self.update_attributes :need_restart => true #fixme ? или не надо рестарт?
  end

  def post_restart
    self.update_attributes :need_restart => false, :source_changed => false, :need_full_restart => false
  end

  def try_backup
    BookBackuper.enqueue(self)
  end
end
