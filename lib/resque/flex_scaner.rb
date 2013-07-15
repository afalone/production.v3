class FlexScaner
  def self.enqueue(production)
    Resque.enqueue(self, production.id)
  end
  @queue = :flex

  def self.perform(production_id)
    production = Production.find(production_id)
    raise "bad task" unless production
    raise "bad state" unless production.flex_printing?
    puts "#{Time.now.strftime "%Y-%m-%d %H:%M:%S"} flex scan #{production.id}"
    Page.scan_path(production, production.working_copy)
    FlexScanedMover.enqueue(production)
  end
end