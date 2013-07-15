class RestartIgniter
  def self.enqueue
    Resque.enqueue(self)
  end
  @queue = :batch
  #scheduled
  def self.perform
    Production.with_state(:restarting).all.each do |prod|
      ProcessRestart.enqueue(prod)
    end
  end
end