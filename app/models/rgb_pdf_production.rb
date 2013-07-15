class RgbPdfProduction < PdfProduction
  def pdc_required?
    false
  end

  def pdf_required?
    true
  end

  def need_scale?
    return false if book.scaled?
    return false unless book.pdf_avg_page_height? and book.pdf_avg_page_width?
    return false if book.pdf_avg_page_width > book.pdf_avg_page_height
    book.pdf_avg_page_width > 590 or book.pdf_avg_page_height > 830 #its a kind of magick. вынести цифры в пресеты
  end

  def preview_required?
    false
  end

  def split_needed?
    true
  end

  def splitted?
    split_needed? and !split_required?
  end

  def rgb_prepare_working_copy
    create_working_copy_catalog
    book.pages.each{|p| p.watermark_page('watermark', File.join(working_copy, "#{p.file_name}_w.pdf")) }
  end

  def prepare_for_upload
    #nothing to do
  end

  def upload_files
    self.preset.output.upload_file(self, "#{book.name}_w.pdf", "#{book.name}.pdf")
  end

  def build_exposable_pdf
    rgb_prepare_working_copy
    #join watermarked. версия в лоб. нормальная - когда будет время заниматься хуйней.
    page_list = book.pages.order('page_no').map{|p| "#{p.file_name}_w.pdf" }.join(' ')
    `cd #{working_copy};pdftk #{page_list} cat output #{book.name}_w.pdf`
    FileUtils.mv(File.join(working_copy, "#{book.name}_w.pdf"), work_catalog, :verbose => true)
  end

  def pdf_checked?
    File.exist?(File.join(work_catalog, "#{book.name}_w.pdf"))
  end

  def process_on_server
    pbook = KnigafundBook.locate_book(book.name)
    raise "no production book" unless pbook
    price = book.pages_count * 0.25
    price = 50.0 if price < 50.0
    pbook.update_attributes :pdf_price => price.ceil, :pdf_owner_payment => (price * 0.5)
    super
  end
end
