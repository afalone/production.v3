class P2fLineSelector
  def self.enqueue
    Resque.enqueue(self)
  end
  @queue = :p2f

  def self.perform
    Production.with_state(:p2f_queue).order("priority desc nulls last").all.each do |prod|
      puts "#{Time.now.strftime "%Y-%m-%d %H:%M:%S"} try schedule print p2f for #{prod.id} #{prod.class.name}"
      unless prod.p2f_required?
        prod.to_p2fline!
        puts "#{Time.now.strftime "%Y-%m-%d %H:%M:%S"} p2f skip for #{prod.id}"
        if prod.p2f_printed?
          FlexStep.enqueue(prod)
        end
        next
      end
      if P2fPrint.select_line(prod)
        prod.to_p2fline!
        puts "#{Time.now.strftime "%Y-%m-%d %H:%M:%S"} p2f inlined for #{prod.id}"
      end
    end
  end
end