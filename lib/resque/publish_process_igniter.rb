class PublishProcessIgniter #todo move code to module
  def self.enqueue
    Resque.enqueue(self)
  end
  @queue = :publish

  def self.perform
    Production.with_state(:confirmed).order("priority desc nulls last").all.each do |prod|
      puts "#{Time.now.strftime "%Y-%m-%d %H:%M:%S"} ignite publish for #{prod.id}"
      PublishIgniter.enqueue(prod)
    end
  end
end