class LabelsController < ApplicationController

  def index
    @search = Label.ransack(params[:q])
    @labels = @search.result.page(params[:page])
    respond_to do |format|
      format.html
      format.json {
        render json: @labels.to_json(:only => [:name, :id]) }
    end
  end

  def show
    @label = Label.find(params[:id])
    @prices = @label.prices.page(params[:page])
  end

end
