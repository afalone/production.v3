class PublishCompressor
  def self.enqueue(production)
    Resque.enqueue(self, production.id)
  end
  @queue = :publish

  def self.perform(production_id)
    production = Production.find_by_id(production_id)
    raise "bad task" unless production
    raise "bad state #{production.state}" unless production.publish_preparing?
    puts "#{Time.now.strftime "%Y-%m-%d %H:%M:%S"} cmpress #{production.id}"
    production.start_publication!
    if production.uploading?
      Uploader.enqueue(production)
      Report.create :who => "PublishReport", :source => "Publisher", :message => "#{production.class.to_s}:#{production.id}##{production.book.name} compressed"
    end
  end
end