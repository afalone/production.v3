class TextExtractStart
  def self.enqueue
    Resque.enqueue(self)
  end
  @queue = :abbyy

  def self.perform
    Production.with_state(:cover_prepared).order("priority desc nulls last").all.each do |prod|
      puts "#{Time.now.strftime "%Y-%m-%d %H:%M:%S"} textextract init for  #{prod.id}"
      TextExtractBookStart.enqueue(prod)
    end
  end
end