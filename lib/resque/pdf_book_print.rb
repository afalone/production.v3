class PdfBookPrint
  def self.enqueue(production)
    Resque.enqueue(self, production.id)
  end
  @queue = :pdf

  def self.perform(production_id)
    production = Production.find_by_id(production_id)
    raise "bad task" unless production
    raise "bad state #{production.state}" unless production.pdc_ready?
    puts "#{Time.now.strftime "%Y-%m-%d %H:%M:%S"} process pdf for #{production.id}"
    production.process_pdf!
    PdfFinish.enqueue(production) if production.pdf_preparing?
  end
end