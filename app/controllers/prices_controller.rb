class PricesController < ApplicationController
  before_action :set_price_range, only: :index

  def index
    @search = Price.ransack(params[:q])
    @prices = @search.result.page(params[:page])
    @record_formats = RecordFormat.all.map{|rf| rf if rf.records.size>0 }.compact
  end

  def show
    @price = Price.find(params[:id])
  end

  private
    def set_price_range
      @price_collection = {'greater than' => :gt, 'lower than' => :lt, 'equals' => :eq}
      @price_low_selected, @price_high_selected = params[:js_select_price_low], params[:js_select_price_high]
    end

end
