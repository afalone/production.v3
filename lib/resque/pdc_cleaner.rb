class PdcCleaner
  def self.enqueue(production)
    Resque.enqueue(self, production.id)
  end
  @queue = :pdc

  def self.perform(production_id)
    production = Production.find_by_id(production_id)
    raise "bad task" unless production
    raise "bad state #{production.state}" unless production.pdc_scaned?
    puts "#{Time.now.strftime "%Y-%m-%d %H:%M:%S"} llz clean for #{production.id}"
    production.done_pdc!
    puts "#{Time.now.strftime "%Y-%m-%d %H:%M:%S"} llz cleaned from #{production.id}"
    PdfBookPrint.enqueue(production) if production.pdc_ready?
  end

end