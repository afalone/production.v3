class CoverBookStep
  def self.enqueue(production)
    Resque.enqueue(self, production.id)
  end
  @queue = :media

  def self.perform(production_id)
    begin
    production = Production.find_by_id(production_id)
    raise "bad task" unless production
    raise "bad state" unless production.preview_prepared?
    puts "#{Time.now.strftime "%Y-%m-%d %H:%M:%S"} gen cover for #{production.id}"
    production.process_cover!
    TextExtractBookStart.enqueue(production) if production.cover_prepared?
    rescue Exception => e
      Report.create(:who => "WorkerError", :source => "CoverBookStep", :message => "on processing #{production_id} gain #{e.message}", :backtrace => e.backtrace)
      raise
    end
  end
end