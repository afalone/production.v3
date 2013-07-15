class Input < ActiveRecord::Base
  has_many :books
  has_many :productions
  belongs_to :output
  belongs_to :preset

  scope :active, where(:is_active=>true)

  def process_batch
    self.rename_files
    self.get_from_batch
  end

  def rename_files
    Dir[File.join(self.source_path, "*.csv")].sort.each do |list|
      puts list
      FasterCSV.foreach(list, {:col_sep => ';'}) do |row|
        puts "#{Time.now.strftime "%Y-%m-%d %H:%M:%S"} #{row}"
        next unless row[0]
        if File.exists? File.join(self.source_path, row[1])
          FileUtils.mv File.join(self.source_path, row[1]), File.join(self.source_path, row[0] + ".pdf")
        elsif File.exists? File.join(self.source_path, Iconv.iconv('utf-8', 'windows-1251', row[1]).join)
          FileUtils.mv File.join(self.source_path, Iconv.iconv('utf-8', 'windows-1251', row[1]).join), File.join(self.source_path, row[0] + ".pdf")
        end
      end
      FileUtils.rm list
    end
#    rename_rsl
  end

  def rename_rsl
    Dir[File.join(source_path, "rsl*.pdf")].sort.each do |fname|
      puts "#{Time.now.strftime "%Y-%m-%d %H:%M:%S"} try rename #{fname}"
      kb = KnigafundBook.where("rgb_file_name = ?", File.basename(fname)).first
      next unless kb
      FileUtils.mv fname, File.join(File.dirname(fname), "#{kb.code}.pdf"), :verbose => true
    end
  end

  def files #masks must be moved to attribute
    return [] if File.exist?(File.join(source_path, 'stop.txt')) or File.exist?(File.join(source_path, 'stop'))
    Dir[File.join(self.source_path, "DDCC-*.pdf")] + Dir[File.join(self.source_path, "ISBN-*.pdf")] + Dir[File.join(self.source_path, "*.csv")] + Dir[File.join(self.source_path, "rsl*.pdf")]
  end

  def get_from_batch
    self.files.sort.each do |file|
      puts file
      begin
        self.register_file(file)
      rescue RegistrationError => e
        Report.create :who => "BatchError", :source => "Registrator",
                    :message => "Input:#{self.id} failed on #{file} with #{e}",
                    :backtrace => e.backtrace
        raise
      end
    end
  end

  def register_file(file)
    #создать production, если надо - книжку
    # пнуть резалку
    #refactor chk book exist
    prod = class_eval([self.class_prefix, 'Production'].join).find_or_register(self, file) #todo Production.class.method
    puts "#{Time.now.strftime "%Y-%m-%d %H:%M:%S"} not registered" unless prod
    raise RegistrationError unless prod and prod.valid?
    # смувить исходник
    puts "#{Time.now.strftime "%Y-%m-%d %H:%M:%S"} start calc md5 #{file}"
    md5 = `md5sum "#{file}"`.split(' ').first
    fsize = File.stat(file).size
    puts "#{Time.now.strftime "%Y-%m-%d %H:%M:%S"} md5 #{md5} size #{fsize}"
    unless File.directory?(prod.work_catalog)
      FileUtils.rm_f(prod.work_catalog, :verbose=>true) if File.exist?(prod.work_catalog)
      FileUtils.mkdir_p prod.work_catalog
    end
    #check file existence and md5
    unless File.exist? prod.book.pdf_work_path #fixme test на бэкап проводить по Book#in_work?
      #todo check backup
      FileUtils.cp file, prod.work_catalog, :verbose => true
    end
    if prod.book.pdf_md5?
      if md5 == prod.book.pdf_md5 and fsize == prod.book.pdf_filesize
        #file not changed, todo restart production to republish
        #cp from backup other required files
        FileUtils.rm file, :verbose => true
        puts "#{Time.now.strftime "%Y-%m-%d %H:%M:%S"} need restart"
        unless prod.created?
          prod.update_attributes :need_restart => true, :need_full_restart => true #todo или неполный рестарт?
          prod.restart_production!
        end
      else
        FileUtils.cp file, prod.work_catalog
        FileUtils.rm file
        prod.book.update_attributes :pdf_md5 => md5, :pdf_filesize => fsize
        prod.book.productions.each{|p| p.update_attributes :need_restart => true, :need_full_restart => true, :source_changed => true }
        unless prod.created?
          prod.need_restart = true
          prod.need_full_restart = true
          prod.restart_production!
        end
        #restart
      end
    else
      FileUtils.cp file, prod.work_catalog
      FileUtils.rm file
      prod.book.update_attributes :pdf_md5 => md5, :pdf_filesize => fsize
    end
    prod.book.update_attributes :in_work => true
    puts "#{Time.now.strftime "%Y-%m-%d %H:%M:%S"} init split for #{prod.id}"
    PdfSplitter.enqueue(prod)
  end

  def has_files?
    not self.files.empty?
  end
end

class DuplicateError < Exception
end
class RegistrationError < Exception
end