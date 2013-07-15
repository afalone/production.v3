class FlexFeeder
  def self.enqueue
    Resque.enqueue(self)
  end
  @queue = :flex

  def self.perform
    Production.with_state(:flex_line).all.each do |prod|
      puts "#{Time.now.strftime "%Y-%m-%d %H:%M:%S"} try schedule print flex for #{prod.id}"
      raise "NYI"
#      if P2fPrint.select_line(prod)
#        prod.start_p2f!
#        P2fPrint.enqueue(prod)
#        puts "p2f queued for #{prod.id}"
#      end
    end
  end
end