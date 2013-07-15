class P2fScanedMover
  def self.enqueue(production)
    Resque.enqueue(self, production.id)
  end
  @queue = :p2f

  def self.perform(production_id)
    production = Production.find(production_id)
    raise "bad task" unless production
    raise "bad state" unless production.p2f_printing?
    puts "#{Time.now.strftime "%Y-%m-%d %H:%M:%S"} p2f mv #{production.id}"
    Page.move_scaned(production)
    if Page.all_moved?(production) and Page.all_scaned?(production)
      production.done_p2f!
      FlexStep.enqueue(production) if production.p2f_printed?
    end
  end
end