class StartSingleProduction
  def self.enqueue(production)
    Resque.enqueue(self, production.id)
  end
  @queue = :batch

  def self.perform(production_id)
    production = Production.find_by_id(production_id)
    raise "invalid task" unless production
    raise "bad state #{production.state} for #{production.id}" unless production.created?
    puts "#{Time.now.strftime "%Y-%m-%d %H:%M:%S"} starting #{production.id}"
    production.start_created!
  end
end