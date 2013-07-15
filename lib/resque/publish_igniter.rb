class PublishIgniter
  def self.enqueue(prod)
    Resque.enqueue(self, prod.id)
  end

  @queue = :publish

  def self.perform(production_id)
    production = Production.find_by_id(production_id)
    raise "bad task" unless production
    raise "bad state #{production.state}" unless production.confirmed?
    puts "#{Time.now.strftime "%Y-%m-%d %H:%M:%S"} init publish for #{production.id}"
    production.to_publish_queue!
    if production.publish_preparing?
      Report.create :who => "PublishReport", :source => "PublishIgniter", :message => "#{production.class.to_s}:#{production.id}##{production.book.name} publishing started"
      PublishCompressor.enqueue(production)
    end
  end
end