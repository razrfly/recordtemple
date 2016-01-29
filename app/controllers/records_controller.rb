class RecordsController < ApplicationController

  def index
    @q = Record.ransack(query_params)
    @records = @q.result.
      includes(:artist, :genre, :label, :record_format).
      uniq.
      page(params[:page])
  end

  def show
    @record = Record.find(params[:id])
  end

  private

  def query_params
    params[:q].try(:reject) do |k, v|
      ['photos_id_not_null', 'songs_id_not_null'].include?(k) && v == '0'
    end
  end
end
