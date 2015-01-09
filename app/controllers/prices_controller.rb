class PricesController < ApplicationController
  before_action :set_price, :only => [:show, :edit, :update, :destroy]

  # def index
  #   @prices = Price.all
  # end

  def show
  end

  def new
    @price = Price.new
  end

  def edit
  end

  def create
    @price = Price.new(price_params)

    if @price.save
      redirect_to artist_path(@artist), :notice => "Price was successfully created."
    else
      render :new
    end
  end

  def update
    if @price.update_attributes(price_params)
      redirect_to artist_path(@artist), :notice => "Price was successfully updated."
    else
      render :edit
    end
  end

  def destroy
    @price.destroy
    redirect_to artist_path(@artist), :notice => "Price was successfully deleted."
  end

  private
    def set_price
      @artist = Artist.find(params[:artist_id])
      @price = Price.find(params[:id])
    end

    def price_params
      params.require(:price).permit(:label_id, :detail, :record_type_id, :footnote)
    end
end
