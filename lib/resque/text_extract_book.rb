class TextExtractBook
  def self.enqueue(production)
    Resque.enqueue(self, production.id)
  end
  @queue = :abbyy

  def self.perform(production_id)
    production = Production.find_by_id(production_id)
    raise "bad task" unless production
    raise "bad state #{production.state}" unless production.text_extracting?
    puts "#{Time.now.strftime "%Y-%m-%d %H:%M:%S"} start text extraction for #{production.id}"
    production.textprocess_done!
    ForConfirmSender.enqueue if production.text_extracted? and rand < 0.3
  end
end