class BooksController < ApplicationController
  before_filter :get_items, :only => [:index]
  before_filter :get_book, :only => [:show, :restart_book]

  def index
  end

  def show

  end

  def restart_book
    @book.restart_book
    respond_to do |format|
      format.html { redirect_to :back, :notice => "#{@book.name} sent to restart" }
      format.js do
        get_items
        render
      end
    end
  end

  protected
  def get_items
    @books = Book.includes(:productions).paginate(:per_page=>100, :page=>(params.andand[:page] || 1))
    #includes(:productions).
  end

  def get_book
    @book = Book.find(params[:id], :include => [:productions, :pages])
  end
end
