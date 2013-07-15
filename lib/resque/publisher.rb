class Publisher
  def self.enqueue(production)
    Resque.enqueue(self, production.id)
  end
  @queue = :publish

  def self.perform(production_id)
    production = Production.find_by_id(production_id)
    raise "bad task" unless production
    raise "bad state #{production.state}" unless production.publishing?
    puts "#{Time.now.strftime "%Y-%m-%d %H:%M:%S"} publishing #{production.id}"
    production.done_publish!
    if production.published?
      Report.create :who => "PublishReport", :source => "Publisher", :message => "#{production.class.to_s}:#{production.id}##{production.book.name} published"
      BookBackuper.enqueue(production)
    end
  end
end