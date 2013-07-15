class ViewonlyProduction < Production
  def split_needed?
    true
  end

  def pdc_required?
    false
  end

  def pdf_required?
    false
  end

  def preview_required?
    false
  end

  def abbyy_required?
    false
  end

  def textextract_required?
    true
  end

  def watermark_required?
    true
  end

  def non_ready_pages
    self.book.pages.view_non_ready
  end

  def required_suffixes
    %w(.pdf.swf _w.pdf.swf)
  end

  def process_on_server
    super
    p_book = ext_book_class.locate_book(book.name)
    p_book.update_attributes :read_only => true
#    unpack_book_on_server
    #extract rar
  end


end
