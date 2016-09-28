class SearchesController < ApplicationController

  def new
    @search = SimpleSearch.new(params[:q])
    respond_to do |format|
      format.html
      format.json do
        @search = @search.map do |row|
          result = {
            term: row.term,
            type: row.searchable_type,
            path: polymorphic_path([generate_path_for(row)])
          }
        end

        render json: @search
      end
    end
  end

  private

  def generate_path_for row
    row.searchable.is_a?(Song) ?
    row.searchable.record : row.searchable
  end
end
