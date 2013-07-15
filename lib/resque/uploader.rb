class Uploader
  extend Resque::Plugins::ExponentialBackoff
  #extend Resque::Plugins::Retry
  #                    1m   30m   4h     12h     1d    1d     1d     1d                    3.5d
  @backoff_strategy = [60, 1800, 14400, 43200, 86400, 86400, 86400, 86400, 86400, 86400, 279200,
                       279200, 279200, 279200, 604800, 604800, 604800, 604800, 604800] #полтора месяца рестартов


  def self.enqueue(production)
    Resque.enqueue(self, production.id)
  end
  @queue = :publish

  @retry_exceptions = [] #only criteria check

    retry_criteria_check do |exception, *args|
      if exception.message =~ /^bad task/ or exception.message =~ /^bad state/
        false # don't retry if we got passed a invalid job id.
      else
        true  # its okay for a retry attempt to continue.
      end
    end



  def self.perform(production_id)
    begin
    production = Production.find_by_id(production_id)
    raise "bad task" unless production
    raise "bad state #{production.state}" unless production.uploading?
    puts "#{Time.now.strftime "%Y-%m-%d %H:%M:%S"} upload #{production.id}"
    production.process_upload!
    if production.publishing?
      Publisher.enqueue(production)
      Report.create :who => "PublishReport", :source => "Uploader", :message => "#{production.class.to_s}:#{production.id}##{production.book.name} uploaded to #{production.preset.output.name}"
    end
    rescue Exception => e
      Report.create :who => "PublishError", :source => "Uploader",
                    :message => "#{production.class.to_s}:#{production.id}##{production.book.name} upload to #{production.preset.output.name} failed with #{e}",
                    :backtrace => e.backtrace
      raise
    end
  end

end