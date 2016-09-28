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
            path: polymorphic_path([row.searchable])
          }
        end
        # raise @search.size.inspect
        render json: @search
      end
    end
  end
end
