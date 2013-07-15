class ReportSender
  #scheduled
  @queue = :prod

  def self.enqueue
    Resque.enqueue(self)
  end

  def self.perform
    list = Report.where(:processed => false, :who => "PublishReport").order("created_at").limit(500)
    unless list.empty?
      puts "#{Time.now.strftime "%Y-%m-%d %H:%M:%S"} report publish for #{list.size} entries"
      PublicationMailer.publish_report(list).deliver
    end
    list.each{|r| r.update_attributes :processed => true }.size
  end
end