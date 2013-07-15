class Output < ActiveRecord::Base
  has_one :preset
  has_many :storages

  def path_for_book(ext_book)
    storages.detect{|s| s.path_for_book(ext_book) }.andand.path_for_book(ext_book)
  end

  def calc_upload_path(ext_book)
    path = self.path_for_book(ext_book)
    path ? File.join(path.full_path, ext_book.files_path) : File.join(self.upload_basedir, ext_book.path_to_files)
  end

  #fixme использовать upload_file_to
  def upload_file(production, filename, dest_name = nil) #only from production book path
    begin
      prod_book = production.ext_book_class.locate_book(production.book.name)
      unless prod_book
        puts "#{Time.now.strftime "%Y-%m-%d %H:%M:%S"} book #{production.book.name} not registered at #{production.ext_book_class}"
        raise "book #{production.book.name} not registered at #{production.ext_book_class}"
      end
      puts prod_book.id
      src = File.join(production.work_catalog, File.basename(filename))
      unless File.exist?(src)
        #grab from backup
        puts "#{Time.now.strftime "%Y-%m-%d %H:%M:%S"} try #{filename} in backups"
        src_pathes = production.book.backup_catalogs.map{|p| File.join p, File.basename(filename) }.select{|p| File.exist? p }
        raise "src #{filename} not found" if src_pathes.empty?
        src = src_pathes.sort{|a, b| File.stat(b).mtime <=> File.stat(a).mtime }.first
      end
      hashed_path = self.path_for_book(prod_book) if prod_book.respond_to?(:hash_directory)
      if hashed_path
        raise "book storage nonready" unless hashed_path.ready?
        puts "#{Time.now.strftime "%Y-%m-%d %H:%M:%S"} dir: #{calc_upload_path(prod_book)}"
        unless File.directory?(calc_upload_path(prod_book))
          puts "#{Time.now.strftime "%Y-%m-%d %H:%M:%S"} creating #{calc_upload_path(prod_book)}"
          Dir.mkdir calc_upload_path(prod_book)
          FileUtils.chmod(0777, calc_upload_path(prod_book))
        end
        puts "#{Time.now.strftime "%Y-%m-%d %H:%M:%S"} to #{File.join(calc_upload_path(prod_book), File.basename(filename))}"
        unless dest_name
          FileUtils.cp src, calc_upload_path(prod_book), :verbose=>true
        else
          FileUtils.cp src, File.join(calc_upload_path(prod_book), dest_name), :verbose=>true
        end

      else
        puts '#{Time.now.strftime "%Y-%m-%d %H:%M:%S"} sftp NYI'
        raise "sftp nyi"
        #sftp_upload_book(book) #todo when sftp fix
      end
    rescue Exception => e
      puts "#{Time.now.strftime "%Y-%m-%d %H:%M:%S"} Exception at upload #{filename} #{e}"
      raise
    end
  end

  def upload_book(production)
    puts "#{Time.now.strftime "%Y-%m-%d %H:%M:%S"} try upload #{production.book.name}"
    upload_file(production, "#{production.book.name}.rar")
    upload_cover(production)
  end

  def upload_file_to(src, dest)
    begin
      unless File.directory?(File.dirname(dest))
        puts "#{Time.now.strftime "%Y-%m-%d %H:%M:%S"} creating #{File.dirname(dest)}"
        Dir.mkdir File.dirname(dest)
        FileUtils.chmod(0777, File.dirname(dest))
      end
      puts "#{Time.now.strftime "%Y-%m-%d %H:%M:%S"} to #{dest}"
      FileUtils.cp src, dest, :verbose=>true
    rescue Exception => e
      puts "#{Time.now.strftime "%Y-%m-%d %H:%M:%S"} exception #{e} at upload file to"
      raise
    end
  end

  def upload_cover(production)
    if File.exist?(File.join(production.work_catalog, "#{production.book.name}.jpg"))
      upload_file_to("#{File.join(production.work_catalog, production.book.name)}.jpg", File.join(cover_upload_basedir, "#{production.book.name}.jpg"))
    elsif File.exist?(File.join(production.work_catalog, "#{production.book.name}.png"))
      prod_book = production.ext_book_class.locate_book(production.book.name)
      if prod_book and prod_book.cover_file_name.blank?
        upload_file_to("#{File.join(production.work_catalog, production.book.name)}.png", File.join(cover_upload_basedir, "#{production.book.name}.png"))
      end
    end
  end
end
