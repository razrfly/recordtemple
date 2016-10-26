class PricesController < ApplicationController
  include SearchQueryHelper

  before_action :set_price, only: [:show]
  before_action :authenticate_user!, only: [:index, :show]

  def index
    @q = Price.ransack(params[:q])

    @result = @q.result.includes(:artist, :label,
      :records, :record_format => :record_type
      )

    respond_to do |format|
      format.html do
        @prices = @result.page(params[:page])
      end
      format.csv { send_data @result.to_csv }
    end
  end

  def show
    remember_last_search_query
  end

  private

  def set_price
    @price = Price.includes(:artist, :label, :record_format,
      records: [:photos]).find(params[:id])
  end
end
