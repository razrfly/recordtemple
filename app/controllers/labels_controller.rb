class LabelsController < ApplicationController
  include SearchQueryHelper

  before_action :set_label, only: [:show]

  def index
    @q = Label.ransack(query_params)

    @result = @q.result.includes(:artists, :genres).uniq

    respond_to do |format|
      format.html do
        @labels = query_params.blank? ? Label.active : @result

        @labels = @labels.page(params[:page])
      end

      format.json do
        @labels = Label.fuzzy_search(name: params[:q]).uniq
        render json: @labels.as_json(only: [:id, :name])
      end
    end
  end

  def show
    @q = Record.where('label_id': @label.id).
      ransack(query_params)

    records_search_results(@q)
    remember_last_search_query
  end

  private

  def set_label
    @label = Label.find(params[:id])
  end
end
