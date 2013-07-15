class PdfPrintStart
  def self.enqueue
    Resque.enqueue(self)
  end
  @queue = :pdf

  #scheduled
  def self.perform
    Production.with_state(:pdc_ready).order("priority desc nulls last").all.each do |prod|
      puts "#{Time.now.strftime "%Y-%m-%d %H:%M:%S"} start pdf printing for #{prod.id}"
      Resque.enqueue(PdfBookPrint, prod.id)
      puts "#{Time.now.strftime "%Y-%m-%d %H:%M:%S"} start pdf printing feeded with #{prod.id}"
    end
  end
end