class PdcScaner
  def self.enqueue(production)
    Resque.enqueue(self, production.id)
  end
  @queue = :pdc

  def self.perform(production_id)
    production = Production.find_by_id(production_id)
    raise "bad task" unless production
    raise "bad state #{production.state}" unless production.pdc_processed?
    puts "#{Time.now.strftime "%Y-%m-%d %H:%M:%S"} llz scan for #{production.id}"
    production.scan_pdc!
    puts "#{Time.now.strftime "%Y-%m-%d %H:%M:%S"} llz scaned from #{production.id}"
    PdcCleaner.enqueue(production)
  end
end