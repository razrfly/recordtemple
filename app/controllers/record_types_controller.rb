class RecordTypesController < ApplicationController

  before_action :all_record_types, only: [:index, :destroy]
  before_action :set_record_type, only: [:destroy]

  def new
    @record_type = RecordType.new
  end

  def create
    @record_type = RecordType.new(record_type_params)
    @record_type.save
  end

  def destroy
    @record_type.destroy
  end

  private

  def all_record_types
    @record_types = RecordType.includes(:records).all
  end

  def record_type_params
    params.require(:record_type).permit(:name)
  end

  def set_record_type
    @record_type = RecordType.find(params[:id])
  end
end
