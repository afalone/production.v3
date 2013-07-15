class ForConfirmSender
  def self.enqueue
    Resque.enqueue(self)
  end
  @queue = :prod

  def self.perform
    Production.with_state(:text_extracted).order("priority desc nulls last").all.each do |prod|
      puts "#{Time.now.strftime "%Y-%m-%d %H:%M:%S"} send #{prod.id} to confirmation waiting"
      prod.done_printing!
    end
  end
end