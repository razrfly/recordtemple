class PricesController < ApplicationController
  before_action :set_price, :only => [:show]

  def index
    @prices = Price.page(params[:page])
  end

  def show
  end

  private
    def set_price
      @price = Price.find(params[:id])
    end

end
