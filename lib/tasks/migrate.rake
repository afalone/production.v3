def get_pdf(oldbook)
  pdf = File.join('/mnt/input/work', oldbook.file_name) if File.exist?(File.join('/mnt/input/work', oldbook.file_name))
  pdf = File.join('/mnt/input/work', "#{oldbook.name}.pdf") if pdf.blank? and File.exist?(File.join('/mnt/input/work', "#{oldbook.name}.pdf"))
  pdf = File.join('/mnt/work', oldbook.file_name) if pdf.blank? and File.exist?(File.join('/mnt/work', oldbook.file_name))
  pdf = File.join('/mnt/work', "#{oldbook.name}.pdf") if pdf.blank? and File.exist?(File.join('/mnt/work', "#{oldbook.name}.pdf"))
  pdf = File.join('/mnt/work/2008', oldbook.file_name) if pdf.blank? and File.exist?(File.join('/mnt/work/2008', oldbook.file_name))
  pdf = File.join('/mnt/work/2008', "#{oldbook.name}.pdf") if pdf.blank? and File.exist?(File.join('/mnt/work/2008', "#{oldbook.name}.pdf"))
  pdf = File.join('/mnt/work/2009', oldbook.file_name) if pdf.blank? and File.exist?(File.join('/mnt/work/2009', oldbook.file_name))
  pdf = File.join('/mnt/work/2009', "#{oldbook.name}.pdf") if pdf.blank? and File.exist?(File.join('/mnt/work/2009', "#{oldbook.name}.pdf"))
  pdf = File.join('/mnt/backup/books', oldbook.file_name) if pdf.blank? and File.exist?(File.join('/mnt/backup/books', oldbook.file_name))
  pdf = File.join('/mnt/backup/books', "#{oldbook.name}.pdf") if pdf.blank? and File.exist?(File.join('/mnt/backup/books', "#{oldbook.name}.pdf"))
  pdf
end

namespace :migration do
  task :describe => :environment do
#defs==================================
    class OldBook < ActiveRecord::Base
      establish_connection :prodold
      set_table_name 'books'
      has_many :pages, :class_name => 'OldPage', :foreign_key => :book_id
      has_and_belongs_to_many :pdc_publish_profiles, :join_table => 'books_pdc_publish_profiles', :association_foreign_key => :pdc_publish_profile_id, :class_name => 'OldPdcPublishProfile', :foreign_key => :book_id
      belongs_to :publish_profile, :class_name => 'OldPublishProfile'
    end

    class OldPage < ActiveRecord::Base
      establish_connection :prodold
      set_table_name 'pages'
      belongs_to :book, :class_name => 'OldBook', :foreign_key => :book_id
    end

    class OldPdcPublishProfile < ActiveRecord::Base
      establish_connection :prodold
      set_table_name 'pdc_publish_profiles'
      has_and_belongs_to_many :books, :join_table => 'books_pdc_publish_profiles', :class_name => 'OldBook', :foreign_key => :pdc_publish_profile_id, :association_foreign_key => :book_id
    end

    class OldReport < ActiveRecord::Base
      establish_connection :prodold
      set_table_name 'reports'
    end

    class OldStat < ActiveRecord::Base
      establish_connection :prodold
      set_table_name 'stats'
    end

    class OldPublishProfile < ActiveRecord::Base
      establish_connection :prodold
      set_table_name 'publish_profiles'
      has_many :books, :class_name => 'OldBook', :foreign_key => :publish_profile_id
    end
#defs==================================
  end

  desc "import books"
  task :test => :describe do
    count = 0
    OldBook.find_each do |oldbook|
      book = Book.find_by_name(oldbook.name)
      next if book
      next if oldbook.name.blank?
      book = Book.create(:name => oldbook.name, :created_at => oldbook.created_at, :pages_count => oldbook.pages_count,
                         :pdf_filename => oldbook.file_name || "#{oldbook.name}.pdf", :doc_pages_count => oldbook.doc_pages_count,
                         :text_pages_count => oldbook.txt_pages_count, :view_pages_count => oldbook.view_pages_count,
                         :quote_pages_count => oldbook.quote_pages_count)
      next unless book.valid?
      oldbook.pages.each do |pg|
        book.pages.create(:page_no => pg.page_no, :quote_ready=>pg.quote_ready?, :view_ready=>pg.view_ready?,
                          :doc_ready=>pg.doc_ready?, :text_ready=>pg.text_ready?, :quote_ready_time => pg.quote_ready_time,
                          :quote_updated_at => pg.quote_updated_at, :doc_ready_time => pg.doc_ready_time,
                          :doc_updated_at => pg.doc_updated_at, :view_ready_time => pg.view_ready_time,
                          :text_updated_at => pg.text_updated_at, :text_ready_time => pg.text_ready_time,
                          :view_updated_at => pg.view_updated_at, :exception => pg.exception?,
                          :exception_at =>pg.exception_at, :manually_preparable => pg.is_manually_preparable?,
                          :quote_created_on_retry => pg.quote_created_on_retry, :created_at => pg.created_at,
                          :view_created_on_retry => pg.view_created_on_retry
        ) unless book.pages.find_by_page_no(pg.page_no)
      end #pages ok
      puts "#{oldbook.name} #{oldbook.pages.count} #{oldbook.pdc_publish_profiles.map(&:name).join(', ')}"
      count += 1
      break if count > 500
    end
    puts count


  end

  task :prods => :describe do
    OldBook.find_each do |oldbook|
      pdf = get_pdf(oldbook)
      unless pdf.blank?
        #md5
        #size && avg
        #todo later
      end
      book = Book.find_by_name(oldbook.name)
      next unless book
      #scan print profiles && publish profiles, generate productions based on its
      unless oldbook.state == 'shop'
        prod = Production.create :book_id => book.id
        case oldbook.publish_profile.andand.name
          when 'tatarian' :
            prod.output = Output.find_by_name('tat')
            prod.input = Input.find_by_name('tat')
          when 'default' :
            prod.output = Output.find_by_name('kf')
            prod.input = Input.find_by_name('kf')
        end
        prod.save!
      end

      oldbook.pdc_publish_profiles.each do |pr|
        prod = PdcProduction.create :book_id => book.id
        case pr.name
          when 'bestkniga' :
            prod.output = Output.find_by_name('bestkniga')
          when 'knigafund' :
            prod.output = Output.find_by_name('knigafund')
        end
        prod.save!
      end

    end
  end

  desc "import published with prods"
  task :import_published => :describe do
    OldBook.where(:state => "published").find_each(:batch_size => 10) do |old_book|
      pdf_file = get_pdf old_book
      puts "pdf not found for #{old_book.name}"
      next
    end
  end
end