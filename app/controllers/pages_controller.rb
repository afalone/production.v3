class PagesController < ApplicationController
  before_filter :get_book, :only => [:index]
  before_filter :get_pages, :only => [:index]
  before_filter :get_page, :only => [:show]
  before_filter :get_productions, :only => [:show, :index]

  def calc_fast_page_numbers(pages)
    fast_select_pages = []
    if pages.size > 10
      ppage = (pages.size - 1) / 9.0
      (1..9).inject(1.0) do |pos, i|
        fast_select_pages << pages[pos.round - 1]
        pos + ppage
      end
      fast_select_pages << pages.last unless fast_select_pages.last == pages.last
    end
    fast_select_pages
  end

  protected :calc_fast_page_numbers

  def show
    respond_to do |format|
        format.html do
          @fast_select_pages = calc_fast_page_numbers((1..@page.book.pages_count).to_a).map{|i| @page.book.pages.find_by_page_no(i) }
          @productions.select{|p| p.confirmation_waiting? }.each do |production|
            if production.p2f_required? #fix на правильное определение наличия swf
              @flash = "/books/#{@page.book.id}/pages/#{@page.id}.swf"
            end


          end
          render
        end
        format.swf do
          # показать свф для ожидающих подтверждения. остальные обойдутся.
          # показывать квоту, если нет - вью.
          # для имеющих превью - показывать превью
          if @productions.detect{|p| p.confirmation_waiting? and p.p2f_required? }
            puts "send swf"
            fn = "#{@page.full_path}.doc.swf" if File.exist?("#{@page.full_path}.doc.swf")
            fn ||= "#{@page.full_path}_w.pdf.swf" if File.exist?("#{@page.full_path}_w.pdf.swf")
            fn ||= "#{@page.full_path}.pdf.swf" if File.exist?("#{@page.full_path}.pdf.swf")
          if fn
            send_data File.read(fn), :name => "res"+Time.now.to_i.to_s+".swf", :disposition => "inline", :type => "application/x-shockwave-flash"
          else
            render :text => "not found"
          end
          end
        end
      end
  end

  def index
  end

 protected
  def get_book
    @book = Book.find(params[:book_id])
  end

  def get_pages
    @pages = @book.pages.order("page_no").paginate(:per_page=>500, :page => (params[:page] || 1))
  end

  def get_page
    @page = Page.find(params[:id])
    @links = [["First", book_page_path(@page.book, @page.book.pages.find_by_page_no(1))],
              (["Prev", book_page_path(@page.book, @page.book.pages.find_by_page_no(@page.page_no - 1))] if @page.page_no > 1),
              (["Next", book_page_path(@page.book, @page.book.pages.find_by_page_no(@page.page_no + 1))] if @page.page_no < @page.book.pages_count),
              ["Last", book_page_path(@page.book, @page.book.pages.find_by_page_no(@page.book.pages_count))] ]
  end

  def get_productions
    @productions = @book.andand.productions
    @productions ||= @page.andand.book.andand.productions
  end
end
