class CoverStep
  def self.enqueue
    Resque.enqueue(self)
  end
  @queue = :media

  def self.perform
    Production.with_state(:preview_prepared).order("priority desc nulls last").all.each do |prod|
      puts "#{Time.now.strftime "%Y-%m-%d %H:%M:%S"} schedule gen cover for #{prod.id}"
      Resque.enqueue(CoverBookStep, prod.id)
    end
  end
end