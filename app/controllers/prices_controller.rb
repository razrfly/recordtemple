class PricesController < ApplicationController
  before_action :set_price, only: [:show]
  after_action :remember_search_query, only: [:index]
  after_action :clear_search_query, only: [:show]

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
    @last_search_query = session[:last_search_query]
  end

  private

  def set_price
    @price = Price.includes(:artist, :label, :record_format,
      records: [:photos]).find(params[:id])
  end

  def clear_search_query
    session[:last_search_query].try(:clear)
  end

  def remember_search_query
    session[:last_search_query] = request.url
  end
end
