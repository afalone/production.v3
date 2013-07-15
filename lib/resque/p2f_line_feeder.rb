class P2fLineFeeder
  def self.enqueue
    Resque.enqueue(self)
  end
  @queue = :p2f

  def self.perform
    Production.with_state(:p2f_line).order("priority desc nulls last").all.each do |prod|
      puts "#{Time.now.strftime "%Y-%m-%d %H:%M:%S"} try schedule print p2f for #{prod.id}"
      if P2fPrint.select_line(prod)
        prod.start_p2f!
        P2fPrint.enqueue(prod)
        puts "#{Time.now.strftime "%Y-%m-%d %H:%M:%S"} p2f queued for #{prod.id}"
      end
    end
  end
end