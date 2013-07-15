class ProductionsController < ApplicationController
  before_filter :get_filter, :only => [:index]
  before_filter :get_book, :only => [:index]
  before_filter :get_items, :only => [:index]
  before_filter :get_item, :only => [:show, :confirm, :edit, :update, :restart]


  def index

  end

  def show
  end

  def edit
  end

  def update
  end

  def confirm
    if @production and @production.confirmation_waiting?
      @production.confirm!
      redirect_to session[:after_confirm] || productions_path(:type=>"confirm")
    else
      redirect_to productions_path
    end
  end

  def restart

    redirect_to :back
  end

  protected
  def get_filter
    @filter = {}
    @filter[:type] = params[:type] unless params[:type].blank?
  end

  def get_book
    @book = Book.find_by_id(params[:book_id])
  end

  def get_items
    @productions = @book.productions.typed(@filter[:type]).includes(:book).paginate(:per_page=>100, :page=>params.andand[:page] || 1) if @book
    @productions ||= Production.typed(@filter[:type]).includes(:book).paginate(:per_page=>100, :page=>params.andand[:page] || 1)
  end

  def get_item
    @production = Production.find(params[:id])
  end
end
