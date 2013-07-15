class PreviewBookStep
  def self.enqueue(production)
    Resque.enqueue(self, production.id)
  end
  @queue = :media

  def self.perform(production_id)
    production = Production.find_by_id(production_id)
    raise "bad task" unless production
    raise "bad state #{production.state}" unless production.pdf_ready?
    puts "#{Time.now.strftime "%Y-%m-%d %H:%M:%S"} gen previews for #{production.id}"
    production.process_preview!
    CoverBookStep.enqueue(production) if production.preview_prepared?
  end
end