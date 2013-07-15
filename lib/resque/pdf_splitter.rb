class NeedRetry < Exception ; end

class PdfSplitter
  extend Resque::Plugins::Retry


  @retry_limit = 3
  @retry_delay = 30
  @retry_exceptions = [NeedRetry]

  def self.enqueue(production)
    Resque.enqueue(self, production.id)
  end
  @queue = :split

  def self.perform(production_id)
    production = Production.find_by_id(production_id)
    raise "invalid task" unless production
    raise "storage error" unless File.directory?(production.work_catalog)
    #split pages, calc average/max pages sizes
      production.book.update_attributes(:locked_at => Time.now)
      puts "#{Time.now.strftime "%Y-%m-%d %H:%M:%S"} prepare #{production.id} for loaded"
      production.to_scaling!
      if production.scaling?
        puts "#{Time.now.strftime "%Y-%m-%d %H:%M:%S"} preloaded #{production.id}"
        PdfScaler.enqueue(production)
      else
        if production.started?
          puts "#{Time.now.strftime "%Y-%m-%d %H:%M:%S"} not preloaded #{production.id}, retry if can"
          Report.create(:who => "WorkerError", :source => "PdfSplitter", :message => "on loading #{production_id} need retry")
          production.book.update_attributes(:locked_at => nil)
          raise NeedRetry
        end
        #todo need fix for state (must start flexprint) PdcBookFeeder.enqueue(production) if production.p2f_printed?
        FlexStep.enqueue(production) if production.p2f_printed?
        puts "#{Time.now.strftime "%Y-%m-%d %H:%M:%S"} moved #{production.id} to state #{production.state}"
      end
      production.book.update_attributes(:locked_at => nil)
  end

end