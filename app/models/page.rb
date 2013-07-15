class Page < ActiveRecord::Base

  belongs_to :book
  scope :text_ready, lambda { where "text_ready = 't'" }
  scope :doc_ready, lambda { where "doc_ready = 't'" }
  scope :abbyy_ready, doc_ready.text_ready
  scope :abbyy_non_ready, lambda { where "doc_ready = 'f' or text_ready = 'f'" }
  scope :view_ready, lambda { where "view_ready = 't'" }
  scope :quote_ready, lambda { where "quote_ready = 't'" }
  scope :p2f_ready, view_ready.quote_ready
  scope :p2f_non_ready, lambda { where "view_ready = 'f' or quote_ready = 'f'" }
  scope :view_non_ready, lambda { where "view_ready != 't'" }
  scope :quote_non_ready, lambda { where "quote_ready != 't'" }
  scope :non_exceptioned, lambda { where "exception != 't'" }
  #todo abbyy exception checker

#  def update_abbyy
#    if File.exists? "#{full_path}.txt"
#        self.update_attributes(:text_ready => true) #todo , :text_updated_at=>Time.now, :text_ready_time => File.stat("#{self.full_path}.txt").mtime
#    end
#    if File.exists? "#{full_path}.doc"
#        self.update_attributes(:doc_ready => true) #todo , :doc_updated_at=>Time.now, :doc_ready_time => File.stat("#{self.full_path}.doc").mtime
#    end
#  end
#
  def file_name
    "page#{self.page_no.to_s.rjust(4,'0')}"
  end

  def full_path
    File.join book.work_catalog, file_name
  end

  def self.scan_path(production, path=nil)
    book = production.book
    if book.pages_count.nil? or book.pages_count <= 0 or book.pages_count != book.pages.count #guard -- need page scan, todo check lost pages
      self.create_from_pdfs(book)
      #book.update_attributes :pages_count => book.pages.count
    end
    book.pages.each do |page|
      file = File.join(path || book.work_catalog, page.file_name)
      upd = {}
      %w(text .txt doc .doc quote .doc.swf view .pdf.swf view _w.pdf.swf).each_slice(2) do |a|
        fn = "#{file}#{a[1]}"
        if File.exist?(fn) and !page.send("#{a[0]}_ready".to_sym)
          upd.merge!("#{a[0]}_ready".to_sym => true)
          upd.merge!("#{a[0]}_ready_time".to_sym => File.stat(fn).mtime)
          upd.merge!("#{a[0]}_updated_at".to_sym => Time.now)
        end
      end
      page.update_attributes upd
    end

    book.update_attributes :view_pages_count => production.book.pages.where(:view_ready=>true).count,
                           :quote_pages_count => production.book.pages.where(:quote_ready=>true).count,
                           :text_pages_count => production.book.pages.where(:text_ready=>true).count,
                           :doc_pages_count => production.book.pages.where(:doc_ready=>true).count
    #todo special case - move files from working copy
  end

  def self.create_from_pdfs(book)
    Dir[File.join(book.work_catalog, "page????.pdf")].each do |page_name|
      page_number = File.basename(page_name, '.pdf')[4,4].to_i
      next if book.pages.find_by_page_no(page_number)
      book.pages.create(:page_no=>page_number)
    end
    book.update_attributes :pages_count => book.pages.count
  end

  def watermark_page(mark_name, destname)
    `pdftk #{full_path}.pdf stamp #{File.join(Rails.root, 'public', "#{mark_name}.pdf")} output #{destname}`
  end

  def copy_page(destpath)
    FileUtils.cp "#{full_path}.pdf", destpath
    FileUtils.cp "#{full_path}.doc", destpath if File.exist?("#{full_path}.doc")
  end

  def scale_page_to_a4 #refactor to print_profile? or to page?
      pathname = "#{full_path}_images"
      FileUtils.rm_f pathname if File.exist? pathname
      `pdfimages -j #{full_path}.pdf #{pathname}`
      Dir["#{pathname}*.jpg"].sort.each do |nm|
        str = `identify #{nm}`
        str.scan(/\s(\d+)x(\d+)\s/) do |w, h|
          width = w.to_i
          height = h.to_i
          puts "#{width} #{height}"
          if width > 590 or height > 830 #595x841
            puts "process page #{page_no}"
            if width > height
              puts "landscape, skip"
              return
            end
            fname = File.join('/tmp', "#{book.name}_#{file_name}")
            begin

              #dx = width * 25.4 / 200
              #dy = height * 25.4 / 285
              #puts "#{dx.to_i} #{dy.to_i}"

              #`convert -density 72x72 '#{full_path}.pdf' -quality 100 '#{fname}.png'`
              #`convert +antialias -density #{dx.to_i}x#{dy.to_i} '#{fname}.png' '#{fname}.pdf'`
              `convert +antialias -density 72x72 -resize 590x830 '#{nm}' '#{fname}.pdf'`
              if File.exist? "#{fname}.pdf"
                FileUtils.mv "#{full_path}.pdf", "#{full_path}.orig.pdf"
                begin
                  FileUtils.cp "#{fname}.pdf", "#{full_path}.pdf"
                rescue
                  FileUtils.mv "#{full_path}.orig.pdf", "#{full_path}.pdf", :force => true
    #            ensure
    #              FileUtils.rm "#{full_path}.bak" if File.exist? "#{full_path}.bak"
                end
              end
            ensure
              FileUtils.rm "#{fname}.pdf" if File.exist? "#{fname}.pdf"
              FileUtils.rm "#{fname}.png" if File.exist? "#{fname}.png"
              FileUtils.rm nm if File.exist?(nm)
            end

          end
        end
      end
#    s = `identify #{full_path}.pdf`
#    s.scan(/ PDF (\d+)x(\d+) /) do |w, h|
#      width = w.to_i
#      height = h.to_i
#    end
  end

  def self.move_scaned(production)
    production.book.pages.each do |page|
      if File.exist?(File.join(production.working_copy, "#{page.file_name}.pdf.swf"))
        if page.view_ready? and (Time.now - page.view_updated_at > 1.minute)
          FileUtils.mv File.join(production.working_copy, "#{page.file_name}.pdf.swf"), production.work_catalog
          FileUtils.rm_f File.join(production.working_copy, "#{page.file_name}.pdf")
        end
      end
      if File.exist?(File.join(production.working_copy, "#{page.file_name}_w.pdf.swf"))
        if page.view_ready? and (Time.now - page.view_updated_at > 1.minute)
          FileUtils.mv File.join(production.working_copy, "#{page.file_name}_w.pdf.swf"), production.work_catalog
          FileUtils.rm_f File.join(production.working_copy, "#{page.file_name}_w.pdf")
        end
      end
    end

    production.book.pages.each do |page|
      if File.exist?(File.join(production.working_copy, "#{page.file_name}.doc.swf"))
        if page.quote_ready? and (Time.now - page.quote_updated_at > 1.minute)
          FileUtils.mv File.join(production.working_copy, "#{page.file_name}.doc.swf"), production.work_catalog
          FileUtils.rm_f File.join(production.working_copy, "#{page.file_name}.doc")
        end
      end
    end
  end

  def self.all_scaned?(production)
    production.non_ready_pages.empty?
  end

  def abbyy_exception? #fixme предполагается, что обрабатываются пдф
    unless exception?
      exc_name = File.join(book.abbyy_exception_catalog, "#{file_name}.pdf")
      if File.exist?(exc_name)
        update_attributes :exception => true, :exception_at => File.stat(exc_name).mtime
      end
    end
    exception?
  end

  def self.all_moved?(production)
    not production.required_suffixes.detect{|suffix| Dir[File.join(production.working_copy, "page????#{suffix}")].size > 0 }
  end

  def confirmable?
    book.productions.with_state(:confirmation_waiting).count > 0
  end
end
