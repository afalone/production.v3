class StartProduction
  def self.enqueue
    Resque.enqueue(self)
  end
  @queue = :batch

  #scheduled
  def self.perform()
    puts "#{Time.now.strftime "%Y-%m-%d %H:%M:%S"} starting created"
    Production.with_state(:created).order("priority desc nulls last").all.each do |prod|
      StartSingleProduction.enqueue(prod)
    end
  end
end