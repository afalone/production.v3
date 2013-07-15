class AutoConfirmer
  def self.enqueue
    Resque.enqueue(self)
  end
  @queue = :prod

  def self.perform
    puts "#{Time.now.strftime "%Y-%m-%d %H:%M:%S"} autoconfirm"
    PdfProduction.with_state(:confirmation_waiting).order("priority desc nulls last").all.each do |prod|
      if File.stat(File.join(prod.work_catalog, "#{prod.book.name}.pdf")).size < 100.megabytes
        puts "#{Time.now.strftime "%Y-%m-%d %H:%M:%S"} autoconfirm #{prod.id}"
        prod.confirm!
        Resque.enqueue(PublishCompressor, prod.id)
      else
        puts "#{Time.now.strftime "%Y-%m-%d %H:%M:%S"} autoconfirm not allowed for #{prod.id} #{prod.class.name} by size restriction"
        prod.update_attributes :error_message => "необходимо подтверждение публикации файла большого размера"
      end
    end
    PdfBestProduction.with_state(:confirmation_waiting).order("priority desc nulls last").all.each do |prod|
      if File.stat(File.join(prod.work_catalog, "#{prod.book.name}.pdf")).size < 100.megabytes
      puts "#{Time.now.strftime "%Y-%m-%d %H:%M:%S"} autoconfirm #{prod.id}"
      prod.confirm!
      Resque.enqueue(PublishCompressor, prod.id)
      else
        puts "#{Time.now.strftime "%Y-%m-%d %H:%M:%S"} autoconfirm not allowed for #{prod.id} #{prod.class.name} by size restriction"
        prod.update_attributes :error_message => "необходимо подтверждение публикации файла большого размера"
      end
    end
    PdcProduction.with_state(:confirmation_waiting).order("priority desc nulls last").all.each do |prod|
      if File.stat(File.join(prod.work_catalog, "#{prod.book.name}.pdc")).size < 100.megabytes
      puts "#{Time.now.strftime "%Y-%m-%d %H:%M:%S"} autoconfirm #{prod.id}"
      prod.confirm!
      Resque.enqueue(PublishCompressor, prod.id)
      else
        puts "#{Time.now.strftime "%Y-%m-%d %H:%M:%S"} autoconfirm not allowed for #{prod.id} #{prod.class.name} by size restriction"
        prod.update_attributes :error_message => "необходимо подтверждение публикации файла большого размера"
      end
    end
    PdcBestProduction.with_state(:confirmation_waiting).order("priority desc nulls last").all.each do |prod|
      if File.stat(File.join(prod.work_catalog, "#{prod.book.name}.pdc")).size < 100.megabytes
      puts "#{Time.now.strftime "%Y-%m-%d %H:%M:%S"} autoconfirm #{prod.id}"
      prod.confirm!
      Resque.enqueue(PublishCompressor, prod.id)
      else
        puts "#{Time.now.strftime "%Y-%m-%d %H:%M:%S"} autoconfirm not allowed for #{prod.id} #{prod.class.name} by size restriction"
        prod.update_attributes :error_message => "необходимо подтверждение публикации файла большого размера"
      end
    end
    RgbPdfProduction.with_state(:confirmation_waiting).order("priority desc nulls last").all.each do |prod|
      if File.stat(File.join(prod.work_catalog, "#{prod.book.name}_w.pdf")).size < 100.megabytes
      puts "#{Time.now.strftime "%Y-%m-%d %H:%M:%S"} autoconfirm #{prod.id}"
      prod.confirm!
      Resque.enqueue(PublishCompressor, prod.id)
      else
        puts "#{Time.now.strftime "%Y-%m-%d %H:%M:%S"} autoconfirm not allowed for #{prod.id} #{prod.class.name} by size restriction"
        prod.update_attributes :error_message => "необходимо подтверждение публикации файла большого размера"
      end
    end
  end
end