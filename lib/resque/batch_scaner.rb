class BatchScaner
  def self.enqueue
    Resque.enqueue(self)
  end
  @queue = :batch

  #scheduled

  def self.perform
    #todo проверить счетчик книг в очередях, пропустить скан при "переполненности"
    puts "#{Time.now.strftime "%Y-%m-%d %H:%M:%S"} scan"
    Input.active.each do |input|
      if input.has_files?
        #puts "#{Time.now.strftime "%Y-%m-%d %H:%M:%S"} +#{input.id}"
        Resque.enqueue BatchLoader, input.id
      end
    end
  end
end