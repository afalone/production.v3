class TextExtractBookStart
  def self.enqueue(production)
    Resque.enqueue(self, production.id)
  end
  @queue = :abbyy #??

  def self.perform(production_id)
    production = Production.find_by_id(production_id)
    raise "bad task" unless production
    raise "bad state #{production.state}" unless production.cover_prepared?
    puts "#{Time.now.strftime "%Y-%m-%d %H:%M:%S"} start text extraction for #{production.id}"
    production.textprocess_start!
    TextExtractBook.enqueue(production) if production.text_extracting?
    ForConfirmSender.enqueue(production) if production.text_extracted?
  end
end