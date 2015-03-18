class RecordTypesController < ApplicationController

  def show
    @record_type = RecordType.find(params[:id])
    @search = @record_type.records.ransack(params[:q])
    @records = @search.result.page(params[:page])

  end

end

