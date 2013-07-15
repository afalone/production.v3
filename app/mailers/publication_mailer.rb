class PublicationMailer < ActionMailer::Base
  default :from => "publish@production.ddc-media.ru", :bcc => "afa.alone@gmail.com"

  def publish_progress
    #to 'afa@ddc-media.ru'
  end

  def stalled(books_list)
    @books = books_list
    mail(:subject => "Books stalled in states", :to => "afa@ddc-media.ru")
  end

  def publish_report(reports)
    @list = reports
    mail(:subject => "Publication report", :to => %w(ekidanova rgolovachev akulakov).map{|s| "#{s}@ddc-media.ru" })
  end

  def errors_report

  end
end
