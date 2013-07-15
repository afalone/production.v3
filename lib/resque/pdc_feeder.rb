class PdcFeeder
  def self.enqueue
    Resque.enqueue(self)
  end
  @queue = :pdc

  #scheduled

  def self.perform
    Production.with_state(:flex_printed).order("priority desc nulls last").all.each do |prod|
      puts "#{Time.now.strftime "%Y-%m-%d %H:%M:%S"} pdc feed for #{prod.id}"
      PdcBookFeeder.enqueue(prod)
    end
  end
end