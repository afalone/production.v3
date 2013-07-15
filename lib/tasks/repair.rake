namespace :repair do
  desc "split /mnt/backup/books by book creation date"
  task :split_backup_books => :environment do
    %w(01 02 03 04 05 06 07 08 09 10 11 12).each{|n| Dir.mkdir(File.join("/mnt/backup/books", n)) unless File.directory?(File.join("/mnt/backup/books", n)) }
    (Dir["/mnt/backup/books/ISBN-*"] + Dir["/mnt/backup/books/DDCC-*"]).sort.each do |name|
      book = Book.find_by_name File.basename(name)
      unless book
        puts "noncreated #{name}"
        next
      end
      selected_path = File.join("/mnt/backup/books", book.created_at.month.to_s.rjust(2, '0'))
      FileUtils.mv name, selected_path, :verbose => true
    end
  end
end