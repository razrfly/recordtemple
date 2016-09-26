class LabelsController < ApplicationController
  include SearchQueryHelper

  before_action :set_label, only: [:show]

  def index
    @q = Label.ransack(params[:q])

    @result = @q.result
      .includes(:artists, :genres)
      .uniq

    respond_to do |format|
      format.html do
        @labels = params[:q].nil? ? Label.active : @result

        @labels = @labels.page(params[:page])
      end

      format.json do
        @labels = params[:q].nil? ? Label.joins(:records) : Label

        @labels = @labels.fuzzy_search(name: params[:q]).uniq
        render json: @labels.as_json(only: [:id, :name])
      end
    end
  end

  def show
    @search = @label.records.ransack(params[:q])
    @records = @search.result.includes(
      :photos, :artist, :record_format
      ).page(params[:page])

    @last_search_query = session[:last_search_query]
  end

  private

  def set_label
    @label = Label.find(params[:id])
  end
end
