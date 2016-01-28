class LabelsController < ApplicationController

  def index
    respond_to do |format|
      format.html do
        @labels = Label.active.page(params[:page])
      end

      format.json do
        @labels = Label.joins(:records).fuzzy_search(name: params[:q]).uniq
        render json: @labels.as_json(only: [:id, :name])
      end
    end
  end

  def show
    @label = Label.find(params[:id])
    @search = @label.records.ransack(params[:q])
    @records = @search.result.page(params[:page])
    @artists = Artist.joins(:records => :label).where('labels.id = ?', @label.id).uniq
  end

end
