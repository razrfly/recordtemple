class SearchesController < ApplicationController

  def index
    @search = Search.search(params[:q])
  end
  
  def autocomplete
    @search = Search.search(params[:term]).where("searchable_type IN ('Artist','Label','Song','Genre')").limit(8)
  end
end


