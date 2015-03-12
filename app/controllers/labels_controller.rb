class LabelsController < ApplicationController

  def index
    @labels = Label.all.page(params[:page])
  end

  def show
    @label = Label.find(params[:id])
    @prices = @label.prices.page(params[:page])
  end

end
