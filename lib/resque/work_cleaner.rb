class WorkCleaner
  def self.enqueue(production)
    Resque.enqueue(self, production.id)
  end
  @queue = :cleanup

  def self.perform(production_id)
    raise "nyi"
    Report.create :who => "PublishReport", :source => "Cleaner", :message => "#{production.class.to_s}:#{production.id}##{production.book.name} backed up"
  end
end