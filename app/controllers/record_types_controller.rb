class RecordTypesController < ApplicationController

  def index
    @record_types = RecordType.with_counted_records
  end
end

