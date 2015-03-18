class LabelsController < ApplicationController

  def index
    @labels = Label.active.page(params[:page])
  end

  def show
    @label = Label.find(params[:id])
    @search = @label.records.ransack(params[:q])
    @records = @search.result.page(params[:page])
    @artists = Artist.joins(:records => :label).where('labels.id = ?', @label.id).uniq
  end

end
