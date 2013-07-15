class P2fScanIgniter
  def self.enqueue
    Resque.enqueue(self)
  end
  @queue = :p2f
  
  def self.perform
    puts "#{Time.now.strftime "%Y-%m-%d %H:%M:%S"} p2f scan ignite"
    Production.with_state(:p2f_printing).each do |prod|
      P2fScaner.enqueue prod
    end
  end
end