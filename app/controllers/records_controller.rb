class RecordsController < ApplicationController

#before_filter :authenticate_user!
#helper_method :sort_column, :sort_direction
#load_and_authorize_resource
  
  def index
    @search = Record.ransack(params[:q])
    @records = @search.result.page(params[:page])

    #@artists = Artist.where('name IN (?)', @search.result.map(&:cached_artist).uniq!)
    #@labels = Label.where('name IN (?)', @search.result.map(&:cached_label).uniq!)
  end

  def show
    @record = Record.find(params[:id])
  end

  def new
    @record = Record.new
    if params[:id]
      @price = Price.find(params[:id])
    end
  end

  def edit
    @record = Record.find(params[:id])
    
    respond_to do |format|
      format.html
      format.js { render :nothing => true }
    end
  end

  def create
    @record = Record.new(params[:record])

    if @record.save
      flash[:notice] = 'Please verify all the details and music or photos!'
      redirect_to edit_record_path(@record)
    else
      render :action => "new"
    end
  end

  def update
    @record = Record.find(params[:id])
    if @record.update_attributes(params[:record])
      flash[:notice] = 'Record was successfully updated.'
      redirect_to @record
    else
      render :action => "edit"
    end
  end

  def destroy
    @record = Record.find(params[:id])
    @record.destroy
  end
  
  private
  
  def sort_column
    params[:sort] ||= "updated_at"
  end
  
  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
  end
  

end
