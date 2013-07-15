class P2fScaner
  def self.enqueue(production)
    Resque.enqueue(self, production.id)
  end
  @queue = :p2f

  def self.perform(production_id)
    production = Production.find(production_id)
    raise "bad task" unless production
    raise "bad state" unless production.p2f_printing?
    puts "#{Time.now.strftime "%Y-%m-%d %H:%M:%S"} p2f scan #{production.id}"
    P2fScanedMover.enqueue(production)
    Page.scan_path(production, production.working_copy)
  end
end