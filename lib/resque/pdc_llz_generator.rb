class PdcLlzGenerator
  def self.enqueue(production)
    Resque.enqueue(self, production.id)
  end
  @queue = :llz

  def self.perform(production_id)
    production = Production.find_by_id(production_id)
    raise "bad task" unless production
    raise "bad state #{production.state}" unless production.pdc_feeded?
    puts "#{Time.now.strftime "%Y-%m-%d %H:%M:%S"} llz #{production.id}"
    production.locklizard_print!
    puts "#{Time.now.strftime "%Y-%m-%d %H:%M:%S"} llzed #{production.id}"
    PdcScaner.enqueue(production) if production.pdc_processed?
  end
end