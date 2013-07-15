class PdcProduction < Production
  def split_required?
    false
  end
  def splitted?
    false
  end

  def pdc_required?
    true
  end

  def pdf_required?
    false
  end

  def preview_required?
    true
  end

  def prepare_for_upload
    #nothing to do
  end

  def upload_files
    self.preset.output.upload_file(self, "#{book.name}.pdc")
    if self.preset.output.require_testpages?
      Dir[File.join(self.work_catalog, "#{self.book.name}_test????.jpg")].each do |nm|
        self.preset.output.upload_file(self, File.basename(nm))
      end
    end
  end

  def process_on_server
    prod_book = KnigafundBook.locate_book(book.name)
    puts "kf book not registered for #{book.name}" unless prod_book
    raise "kf book not registered for #{book.name}" unless prod_book
    puts "llz not processed for #{book.name}" unless book.locklizard_docid
    raise "llz not processed for #{book.name}" unless book.locklizard_docid
    puts "llz already prepared for #{book.name}" if prod_book.locklizard_docid and prod_book.locklizard_docid.to_i != book.locklizard_docid
    raise "llz already prepared for #{book.name}" if prod_book.locklizard_docid and prod_book.locklizard_docid.to_i != book.locklizard_docid
    prod_book.update_attributes :locklizard_docid => book.locklizard_docid, :is_available_for_download => true
    #set downloadable and filesize
  end
end
