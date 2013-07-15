class AbbyyFetcher
  def self.enqueue(production)
    Resque.enqueue(self, production.id)
  end
  @queue = :abbyy

  def self.perform(production_id = nil)
    unless production_id
      Production.with_state(:in_abbyy).all.each do |prod|
        puts "#{Time.now.strftime "%Y-%m-%d %H:%M:%S"} ping #{prod.id}"
        AbbyyFetcher.enqueue(prod)
      end
    else
      production = Production.find(production_id)
      raise "bad task" unless production
      raise "bad state" unless production.in_abbyy?
      production.from_abbyy!
      if production.p2f_queue?
        FileUtils.rm_rf production.book.abbyy_out_catalog if File.exists?(production.book.abbyy_out_catalog)
        puts "#{Time.now.strftime "%Y-%m-%d %H:%M:%S"} abbyy ready #{production.book.name}"
      end
    end
  end

end