class NeedRetry < Exception ; end
class PdfScaler
  extend Resque::Plugins::Retry

  @retry_limit = 3
  @retry_delay = 300
  @retry_exceptions = [NeedRetry]

  def self.enqueue(production)
    Resque.enqueue(self, production.id)
  end
  #@queue = :batch
  @queue = :split

  def self.perform(production_id)
    production = Production.find_by_id(production_id)
    raise "bad task" unless production
    raise "bad state" unless production.scaling?
    puts "#{Time.now.strftime "%Y-%m-%d %H:%M:%S"} to scale #{production.id}"
    production.book.update_attributes(:locked_at => Time.now)
    begin
      production.to_loaded!
    rescue Exception => e
      puts "exc #{e}"
      puts e.backtrace.split("\n").first(5)
      Report.create :source => "PdfScaler", :who => "ProcessError", :message => e, :backtrace => e.backtrace
      raise NeedRetry
    end
    if production.loaded?
      puts "#{Time.now.strftime "%Y-%m-%d %H:%M:%S"} loaded #{production.id}"
    else
      if production.scaling?
        puts "#{Time.now.strftime "%Y-%m-%d %H:%M:%S"} not loaded #{production.id}, retry if can"
        Report.create(:who => "WorkerError", :source => "PdfScaler", :message => "on loading #{production_id} need retry")
        raise NeedRetry
      end
      #todo need fix for state (must start flexprint) PdcBookFeeder.enqueue(production) if production.p2f_printed?
      FlexStep.enqueue(production) if production.p2f_printed?
      puts "#{Time.now.strftime "%Y-%m-%d %H:%M:%S"} moved #{production.id} to state #{production.state}"
    end
    production.book.update_attributes(:locked_at => nil)
  end
end