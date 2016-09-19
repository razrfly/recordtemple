class LabelsController < ApplicationController

  def index
    @q = Label.ransack(query_params)

    @result = @q.result
      .includes(:records, :artists, :genres)
      .uniq

    respond_to do |format|
      format.html do
        @labels = @result.page(params[:page])
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

  private

  def query_params
    params[:q].try(:reject) do |k, v|
      ['records_id_not_null'].include?(k) && v == '0'
    end
  end
end
