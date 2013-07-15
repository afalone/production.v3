class PdcBestProduction < PdcProduction
  def ext_book_class
    BestBook
  end

  def process_on_server
    prod_book = BestBook.locate_book(book.name)
    raise "best book not registered for #{book.name}" unless prod_book
    fmt           = prod_book.formats.find_by_name('SPDF')
    fname         = File.join(work_catalog, "#{book.name}.pdc") if File.exist?(File.join(work_catalog, "#{book.name}.pdc"))
    fname ||= File.join(self.book.backup_catalogs.find{|n| File.join(n, "#{book.name}.pdc")}, "#{book.name}.pdc") if self.book.backup_catalogs.detect{|n| File.join(n, "#{book.name}.pdc") }
    fmt_file_size = File.stat(fname).size #fixme - store pdc size in books
    unless fmt
      #mk format
      prod_book.formats.create :name      =>'SPDF', :file_path => "#{book.name}.pdc",
                               :file_size => fmt_file_size,
                               :price     => prod_book.add_info[:price],
                               :owner_cut => prod_book.add_info[:owner_cut],
                               :locklizard_docid => book.locklizard_docid
      #done
    else
      if prod_book.formats.where(:name=>'SPDF').count > 1
        puts "too many SPDF formats for book #{book.name}"
        raise "too many SPDF formats for book #{book.name}"
        #todo Report.add
      end # слишком много форматов
      fmt = prod_book.formats.where(:name=>'SPDF').first
      to_update = {}
      unless fmt.locklizard_docid and fmt.locklizard_docid =~ /^\d+$/
        to_update[:locklizard_docid] = book.locklizard_docid if book.locklizard_docid and book.locklizard_docid =~ /^\d+$/
      end
      if fmt.price.to_f <= 0.0
        to_update[:price] = prod_book.add_info[:llz_price] if prod_book.add_info and prod_book.add_info.has_key?(:llz_price)
      end
      if fmt.owner_cut.to_f <= 0.0
        to_update[:owner_cut] = prod_book.add_info[:llz_owner_cut] if prod_book.add_info and prod_book.add_info.has_key?(:llz_owner_cut)
      end
      if fmt.price.to_f <= 0.0 and !to_update.has_key?(:price)
        to_update[:price] = prod_book.add_info[:price] if prod_book.add_info and prod_book.add_info.has_key?(:price)
      end
      if fmt.owner_cut.to_f <= 0.0 and !to_update.has_key?(:owner_cut)
        to_update[:owner_cut] = prod_book.add_info[:owner_cut] if prod_book.add_info and prod_book.add_info.has_key?(:owner_cut)
      end
      if fmt.file_size.blank? or fmt.file_size != fmt_file_size
        to_update[:file_size] = fmt_file_size
      end
      fmt.update_attributes to_update unless to_update.empty?
    end

  end

  def preview_required?
    true
  end
end
