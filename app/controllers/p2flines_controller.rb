class P2flinesController < ApplicationController
  def show
  end

  def edit
  end

  def update
  end

  def index
    @lines = P2fline.order("id").all
  end

end
