class SearchesController < ApplicationController


  def index

  end

  def new
    # binding.pry
    @search = Search.new(params[:q])
    @search = @search.map do |row|
      {
        name: row.term,
        type: row.searchable_type,
        path: polymorphic_path(row.searchable),
      }
    end
    respond_to do |format|
      format.html
      format.json { render json: @search }
    end
  end
end
