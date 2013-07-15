class AbbyyFeeder
  def self.enqueue
    Resque.enqueue(self)
  end
  @queue = :abbyy
  #scheduled
  def self.perform
    begin
    #todo move logic to production model
    pages_in_abbyy = Production.with_state(:in_abbyy).all.inject(0) do |rez, prod|
      rez + prod.book.pages_count
    end
    #return if pages_in_abbyy > 300 #todo вынести цифру из кода (watermarks?)
    puts "#{Time.now.strftime "%Y-%m-%d %H:%M:%S"} abbyy feed ready #{Production.with_state(:loaded).count}, in abbyy #{pages_in_abbyy} pages"
    Production.with_state(:loaded).order("priority desc nulls last").all.each do |prod| #todo ограничить количество одновременно загружаемых книг
      next if prod.book.locked_at? and prod.book.locked_at > 1.hour.ago #час на загрузку в абби
      unless prod.abbyy_required?
        AbbyyBookFeeder.enqueue prod
        next
      end
      next if pages_in_abbyy > 300
      #todo move lock check to model
      #lock prod for loading
      prod.book.update_attributes :locked_at => Time.now
      AbbyyBookFeeder.enqueue prod
      pages_in_abbyy += prod.book.pages_count
    end
  rescue Exception => e
    Report.create(:who => "WorkerError", :source => "AbbyyFeeder", :message => "gain #{e.message}", :backtrace => e.backtrace)
    raise
  end

  end
end