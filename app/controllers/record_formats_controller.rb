class RecordFormatsController < ApplicationController
  before_action :set_record_format, :only => [:show]

  def index
    @record_formats = RecordFormat.all.includes(:record_type)
  end

  def show
  end

  private
    def set_record_format
      @record_format = RecordFormat.includes(:record_type).find(params[:id])
    end

end
