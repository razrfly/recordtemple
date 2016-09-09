class PricesController < ApplicationController
  before_action :set_price, only: [:show]

  def index
    @q = Price.ransack(params[:q])

    @result = @q.result.includes(
      :artist, :label, :record_format, :records
      ).uniq

    respond_to do |format|
      format.html do
        @prices = @result.page(params[:page])
      end
      format.csv { send_data @result.to_csv }
    end
  end

  def show
  end

  private

  def set_price
    @price = Price.includes(:record_format,
      :artist, :label, :user).find(params[:id])
  end
end
