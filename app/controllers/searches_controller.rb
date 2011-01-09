class SearchesController < ApplicationController

  def index
    @search = Search.search(params[:q])
  end

  def show
    @search = Search.search(params[:search][:term])
  end

  def new
    @search = Search.new
  end

  def create
    @search = Search.new(params[:search])
    if @search.valid?
      if @search.searchable_id
        redirect_to records_path((@search.searchable_type.downcase + "_id").to_sym => @search.searchable_id)
      else
        @search = Search.search(@search.term)
        render :action => 'show'
      end
    else
      render :action => 'new'
    end
  end
  
  def autocomplete
    @search = Search.search(params[:term]).where("searchable_type IN ('Artist','Label','Song','Genre')").limit(8)
  end
end


