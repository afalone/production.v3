class BatchLoader
  def self.enqueue(input)
    Resque.enqueue(self, input.id)
  end
  @queue = :batch

  #не рестартуемый.

  def self.perform(input_id)
    begin
      input = Input.find(input_id)
      puts "#{Time.now.strftime "%Y-%m-%d %H:%M:%S"} scan input #{input.id}"
      input.process_batch
    rescue Exception => e
      Report.create(:who => "WorkerError", :source => "BatchLoader", :message => "gain #{e.message}", :backtrace => e.backtrace)
      raise
    end

  end
end