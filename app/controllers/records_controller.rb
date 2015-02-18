class RecordsController < ApplicationController

  def index
    @search = Record.ransack(params[:q])
    @records = @search.result.page(params[:page])

    @record_formats = RecordFormat.with_records
    @genres = Genre.with_records
    @conditions = Record.condition_collection

    unless @records.kind_of?(Array)
      @records = @records.page(params[:page])
    else
      @records = Kaminari.paginate_array(@records).page(params[:page])
    end
  end

  def show
    @record = Record.find(params[:id])
  end

end
