class FlexScanedMover
  def self.enqueue(production)
    Resque.enqueue(self, production.id)
  end
  @queue = :flex

  def self.perform(production_id)
    production = Production.find(production_id)
    raise "bad task" unless production
    raise "bad state" unless production.flex_printing?
    puts "#{Time.now.strftime "%Y-%m-%d %H:%M:%S"} flex mv #{production.id}"
    Page.move_scaned(production)
    if Page.all_moved?(production) and Page.all_scaned?(production)
      production.done_flex!
      PdcBookFeeder.enqueue(production) if production.flex_printed?
    end
  end
end