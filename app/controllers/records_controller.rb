class RecordsController < ApplicationController

  def index
    @q = Record.where(user_id: 1).ransack(query_params)
    @records = @q.result.
      includes(:artist, :genre, :label, :price, :record_format, :songs).
      uniq.
      page(params[:page])
  end

  def show
    @record = Record.
      includes(:artist, :genre, :label, :price, :record_format, :songs).
      find(params[:id])
  end

  private

  def query_params
    params[:q].try(:reject) do |k, v|
      ['photos_id_not_null', 'songs_id_not_null'].include?(k) && v == '0'
    end
  end
end
