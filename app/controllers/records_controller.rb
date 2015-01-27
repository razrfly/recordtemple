class RecordsController < ApplicationController
  before_action :set_record, only: [:show]
  def index
    @search = Record.ransack(params[:q])
    @records = @search.result.page(params[:page])
  end

  def show
  end

  def new
    @record = Record.new
    set_record if params[:id]
  end

  private
    def set_record
      @record = Record.find(params[:id])
    end

end
