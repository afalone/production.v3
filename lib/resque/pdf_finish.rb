class PdfFinish
  def self.enqueue(production)
    Resque.enqueue(self, production.id)
  end
  @queue = :pdf

  def self.perform(production_id)
    production = Production.find_by_id(production_id)
    raise "bad task" unless production
    raise "bad state #{production.state}" unless production.pdf_preparing?
    puts "#{Time.now.strftime "%Y-%m-%d %H:%M:%S"} finish pdf print #{production.id}"
    production.done_pdf!
    PreviewBookStep.enqueue(production) if production.pdf_ready?
  end
end