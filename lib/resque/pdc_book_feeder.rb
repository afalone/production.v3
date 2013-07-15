class PdcBookFeeder
  def self.enqueue(production)
    Resque.enqueue(self, production.id)
  end
  @queue = :pdc

  def self.perform(production_id)
    production = Production.find_by_id(production_id)
    raise "bad task" unless production
    raise "bad state #{production.state}" unless production.flex_printed?
    puts "#{Time.now.strftime "%Y-%m-%d %H:%M:%S"} feed llz for #{production.id}"
    production.to_locklizard!
    puts "#{Time.now.strftime "%Y-%m-%d %H:%M:%S"} feeded llz with #{production.id}"
    PdcLlzGenerator.enqueue(production) if production.pdc_feeded?
    PdfBookPrint.enqueue(production) if production.pdc_ready?
  end
end