class FlexStep
  def self.enqueue(prod)
    Resque.enqueue(self, prod.id)
  end

  @queue = :flex

  def self.perform(production_id)
    production = Production.find(production_id)
    raise "bad task" unless production
    raise "bad state" unless production.p2f_printed?
    puts "#{Time.now.strftime "%Y-%m-%d %H:%M:%S"} flex startup #{production.id}"
    production.to_flex!
    FlexScanedMover.enqueue(production) if production.flex_queue?
    PdcBookFeeder.enqueue(production) if production.flex_printed?
  end
end