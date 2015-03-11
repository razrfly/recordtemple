class RecordsController < ApplicationController

  def index
    @records = Record.all.page(params[:page])
  end

  def show
    @record = Record.find(params[:id])
  end

end
