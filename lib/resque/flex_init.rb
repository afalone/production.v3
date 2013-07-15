class FlexInit
  def self.enqueue
    Resque.enqueue(self)
  end
  @queue = :flex

  def self.perform
    Production.with_state(:flex_line).order("priority desc nulls last").all.each do |prod|
      puts "#{Time.now.strftime "%Y-%m-%d %H:%M:%S"} try schedule print flex for #{prod.id}"
      prod.start_flex!
      FlexPrint.enqueue(prod)
      puts "#{Time.now.strftime "%Y-%m-%d %H:%M:%S"} flex queued for #{prod.id}"
    end
  end
end