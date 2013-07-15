class MainController < ApplicationController
  before_filter :get_items
  def index
  end

  protected
  def get_items
    @productions = Production.includes(:book).paginate(:per_page=>100, :page=>(params.andand[:page] || 1))
  end
end
