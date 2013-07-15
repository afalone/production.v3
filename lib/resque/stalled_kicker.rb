class StalledKicker
  def self.enqueue
    Resque.enqueue(self)
  end
  @queue = :batch

  def self.run_stale_check(in_state)
    Production.where("updated_at < now() - '24 hours'::interval").with_state(in_state).all.each do |prod|
      puts "#{Time.now.strftime "%Y-%m-%d %H:%M:%S"} process #{prod.id} with #{trans_sym.to_s}"
      if prod.stale? and block_given? #fixme
        yield(prod)
      else
        Report.create(:who => "StalledError", :source => "StalledKickerr", :message => "on processing #{trans_sym.to_s} #{prod.id} stalled in state #{in_state.to_s}")
      end
    end
  end

  #scheduled
  def self.perform()
    run_stale_check(:started){|production| PdfSplitter.enqueue(production) }
  end
end