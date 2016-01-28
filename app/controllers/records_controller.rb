class RecordsController < ApplicationController

  def index
    @q = Record.ransack(params[:q])
    @records = @q.result.
      includes(:artist, :genre, :record_format).
      page(params[:page])
  end

  def show
    @record = Record.find(params[:id])
  end

end
