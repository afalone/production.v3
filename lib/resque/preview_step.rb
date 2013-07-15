class PreviewStep
  def self.enqueue
    Resque.enqueue(self)
  end
  @queue = :media

  def self.perform
    Production.with_state(:pdf_ready).order("priority desc nulls last").all.each do |prod|
      puts "#{Time.now.strftime "%Y-%m-%d %H:%M:%S"} preview schedule for #{prod.id}"
      Resque.enqueue(PreviewBookStep, prod.id)
    end
  end
end