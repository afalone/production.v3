class P2fScanIgniter
  def self.enqueue
    Resque.enqueue(self)
  end
  @queue = :flex
  
  def self.perform
    puts "#{Time.now.strftime "%Y-%m-%d %H:%M:%S"} p2f scan ignite"
    Production.with_state(:p2f_printing).order("priority desc nulls last").each do |prod|
      Resque.enqueue(P2fScaner, prod.id)
    end
  end
end