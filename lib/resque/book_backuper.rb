class NeedRetry < Exception; end
class BookBackuper

  extend Resque::Plugins::ExponentialBackoff
  #extend Resque::Plugins::Retry
  #                    1m   30m   4h     12h     1d    1d     1d     1d                    3.5d
  @backoff_strategy = [60, 1800, 14400, 43200, 86400, 86400, 86400, 86400, 86400, 86400, 279200,
                       279200, 279200, 279200, 604800, 604800, 604800, 604800, 604800] #полтора месяца рестартов

  @retry_exceptions = [NeedRetry] #only criteria check

#    retry_criteria_check do |exception, *args|
#      if exception.message =~ /^bad task/ or exception.message =~ /^bad state/
#        false # don't retry if we got passed a invalid job id.
#      else
#        true  # its okay for a retry attempt to continue.
#      end
#    end

  @queue = :prod

  def self.enqueue(prod)
    Resque.enqueue(self, prod.id)
  end

  def self.perform(production_id)
    production = Production.find(production_id)
    raise "bad task" unless production
    book = production.book
    raise "bad state" unless production.published?
    raise "not in work" unless book.in_work?
    raise "not allowed" unless book.productions.all?{|p| p.published? }
    puts "#{Time.now.strftime "%Y-%m-%d %H:%M:%S"} try backup #{production.id} #{book.id}"
    begin
      book.move_files_to_backup
      Report.create(:who => "WorkerReport", :source => "BookBackuper", :message => "Book #{book.id} #{book.name} backed up")
      puts "#{Time.now.strftime "%Y-%m-%d %H:%M:%S"} backed #{production.id}"
    rescue Exception => e
      Report.create(:who => "WorkerError", :source => "AbbyyFeeder", :message => "gain #{e.message}", :backtrace => e.backtrace)
      raise NeedRetry
    end
  end


end