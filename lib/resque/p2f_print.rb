class P2fPrint


  def self.enqueue(production)
    Resque::Job.create(select_queue(production), self, production.id)
  end

  def self.select_line(production)
    #todo fix selecting rule
    P2fline.all.detect{|l| l.active? and !(l.can_view? ^ production.preset.require_view_printing?) and !(l.can_quote? ^ production.preset.require_quote_printing?)}
  end

  def self.select_queue(production)
    ln = select_line(production)
    raise "queue not found for #{production.id}" unless ln
    "p2f_line_#{ln.id}"
  end

  @wait_time = 5.minutes


  #временно
  #print wildcard
  def self.perform(production_id)
    line = P2fline.find(LINE_ID)
    puts "#{Time.now.strftime "%Y-%m-%d %H:%M:%S"} line #{line.name}"
    production = Production.find(production_id)
    raise "bad task" unless production
    raise "bad state" unless production.p2f_printing?
    tm = Time.now
    p2f_print_do(production)
    puts "#{Time.now.strftime "%Y-%m-%d %H:%M:%S"} Done p2fing #{production.id} in #{Time.now - tm}"
    P2fScaner.enqueue(production) if production.p2f_printing?
    #schedule scan process (default => +5 minutes)
  end

  def self.run_command(cmd)
    puts "#{Time.now.strftime "%Y-%m-%d %H:%M:%S"} #{cmd}"
    pipe = IO.popen(cmd)
    pid  = pipe.pid
    Process.wait(pid)
  end

  def self.p2f_print_do(production) #TODO!!!
    #running at winmachine
    if production.preset.require_view_printing?
      opts = "/BeforePrintingTimeout:#{production.preset.view_before_printing_timeout} /PrintingTimeout:#{production.preset.view_printing_timeout} /AfterPrintingTimeout:#{production.preset.view_after_printing_timeout} /KillProcessIfTimeout:on"
      cmd = "p2fServer.exe #{File.join(production.p2f_work_path, "page*.pdf").gsub("/", "\\")} #{production.p2f_work_path.gsub("/", "\\")} /ProtectionOptions:7 /InterfaceOptions:0 #{opts} /CreateLogFile:on /LogFileName:#{File.join(production.p2f_work_path, "p2f_view.log").gsub("/", "\\")}"
      run_command(cmd)

    end
    if production.preset.require_quote_printing?
      opts = "/BeforePrintingTimeout:#{production.preset.quote_before_printing_timeout} /PrintingTimeout:#{production.preset.quote_printing_timeout} /AfterPrintingTimeout:#{production.preset.quote_after_printing_timeout} /KillProcessIfTimeout:on"
      cmd = "p2fServer.exe #{File.join(production.p2f_work_path, "*.doc").gsub("/", "\\")} #{production.p2f_work_path.gsub("/", "\\")} /ProtectionOptions:5 /InterfaceOptions:0 #{opts} /CreateLogFile:on /LogFileName:#{File.join(production.p2f_work_path, "p2f_quote.log").gsub("/", "\\")}"
      run_command(cmd)
    end

  end

  def p2f_stop(production)

  end



end