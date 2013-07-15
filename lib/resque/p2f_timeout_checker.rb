class P2fTimeoutChecker
  def self.enqueue
    Resque.enqueue(self)
  end
  @queue = :p2f_line

  def self.perform
    line = P2fline.find(LINE_ID)
    line.clean_processes
  end

end