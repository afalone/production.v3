class FlexPrint


  def self.enqueue(production)
    Resque.enqueue(self, production.id)
  end

#  def self.enqueue(production)
#    Resque::Job.create(select_queue(production), self, production.id)
#  end
#
#  def self.select_line(production)
#    #todo fix selecting rule
#    P2fline.all.detect{|l| l.active? and !(l.can_view? ^ production.preset.require_view_printing?) and !(l.can_quote? ^ production.preset.require_quote_printing?)}
#  end
#
#  def self.select_queue(production)
#    ln = select_line(production)
#    raise "queue not found for #{production.id}" unless ln
#    "p2f_line_#{ln.id}"
#  end
#
  @wait_time = 5.minutes
  @queue = :flex

  #временно
  #print wildcard
  def self.perform(production_id)
#    line = P2fline.find(LINE_ID)
#    puts "line #{line.name}"
    production = Production.find(production_id)
    raise "bad task" unless production
    raise "bad state" unless production.flex_printing?
    tm = Benchmark.ms do
      p2f_print_do(production)
    end
    puts "#{Time.now.strftime "%Y-%m-%d %H:%M:%S"} Done p2fing #{production.id} in #{tm}"
    FlexScaner.enqueue(production) if production.flex_printing?
    #schedule scan process (default => +5 minutes)
  end

  def self.p2f_print_do(production) #TODO!!!

    #pdf2swf page0010.pdf -o page0010.swf -z -T 9 -t -G -S
    #pdf2swf pg_0042.pdf -o Paper.swf -f -T 9 -t -G -s storeallcharacters
    #running at winmachine
    if production.preset.require_view_printing? and production.require_flex?
#      opts = "/BeforePrintingTimeout:#{production.preset.view_before_printing_timeout} /PrintingTimeout:#{production.preset.view_printing_timeout} /AfterPrintingTimeout:#{production.preset.view_after_printing_timeout} /KillProcessIfTimeout:on"
#      cmd = "p2fServer.exe #{File.join(production.p2f_work_path, "*.pdf").gsub("/", "\\")} #{production.p2f_work_path.gsub("/", "\\")} /ProtectionOptions:7 /InterfaceOptions:0 #{opts} /CreateLogFile:on /LogFileName:#{File.join(production.p2f_work_path, "p2f_view.log").gsub("/", "\\")}"
      production.book.pages do |page|
        cmd = "pdf2swf #{}.pdf -o #{}.pdf.swf -z -T 9 -t -G -S"
        puts "#{Time.now.strftime "%Y-%m-%d %H:%M:%S"} #{cmd}"
        pipe = IO.popen(cmd)
        pid = pipe.pid
        Process.wait(pid)
      end
    end
    if production.preset.require_quote_printing?
      opts = "/BeforePrintingTimeout:#{production.preset.quote_before_printing_timeout} /PrintingTimeout:#{production.preset.quote_printing_timeout} /AfterPrintingTimeout:#{production.preset.quote_after_printing_timeout} /KillProcessIfTimeout:on"
      cmd = "p2fServer.exe #{File.join(production.p2f_work_path, "*.doc").gsub("/", "\\")} #{production.p2f_work_path.gsub("/", "\\")} /ProtectionOptions:5 /InterfaceOptions:0 #{opts} /CreateLogFile:on /LogFileName:#{File.join(production.p2f_work_path, "p2f_quote.log").gsub("/", "\\")}"
      puts "#{Time.now.strftime "%Y-%m-%d %H:%M:%S"} #{cmd}"
      pipe = IO.popen(cmd)
      pid = pipe.pid
      Process.wait(pid)

    end

  end

  def p2f_stop(production)

  end



end