class ProcessRestart
  def self.enqueue(production)
    Resque.enqueue(self, production.id)
  end

  @queue = :batch

  def self.perform(production_id)
    production = Production.find(production_id)
    raise "bad task" unless production
    raise "bad state #{production.state}" unless production.loaded?
    production.do_restart!
  end
end