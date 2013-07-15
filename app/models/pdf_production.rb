class PdfProduction < Production #kf
  def abbyy_required?
    false
  end

  def split_needed?
    false
  end

  def splitted?
    false
  end

  def pdc_required?
    false
  end

  def pdf_required?
    true
  end

  def preview_required?
    true
  end

  def p2f_required?
    false
  end

  def prepare_for_upload
    #nothing to do
  end

  def upload_files
    self.preset.output.upload_file(self, book.pdf_work_path)
    if self.preset.output.require_testpages?
      Dir[File.join(self.work_catalog, "#{self.book.name}_test????.jpg")].each do |nm|
        self.preset.output.upload_file(self, File.basename(nm))
      end
    end
    if KnigafundBook.locate_book(book.name).andand.cover_file_name.blank?
      preset.output.upload_cover(self)
      #todo send
    end
  end

  def process_on_server
    puts "need process?"
    puts "set kf downloadable flag"
    KnigafundBook.locate_book(book.name).update_attributes :is_available_for_download => true
  end
end
