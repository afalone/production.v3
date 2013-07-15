class AbbyyBookFeeder
  def self.enqueue(production)
    Resque.enqueue(self, production.id)
  end
  @queue = :abbyy

  def self.perform(production_id)
    begin
    production = Production.find(production_id)
    raise "bad task" unless production
    raise "bad state #{production.state}" unless production.loaded?
    production.to_abbyy!
    production.book.update_attributes :locked_at => nil
    rescue Exception => e
      Report.create(:who => "WorkerError", :source => "AbbyyBookFeeder", :message => "on processing #{production_id} gain #{e.message}", :backtrace => e.backtrace)
      raise
    end

  end
end