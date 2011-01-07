class RecordsController < ApplicationController

before_filter :authenticate_user!
helper_method :sort_column, :sort_direction

  def index
    @search = Search.new
    
    @records = Record.scoped
    @records = @records.where(:user_id => current_user.id)
    @records = @records.joins(:songs) if params[:mp3]
    @records = @records.where(:artist_id => params[:artist_id])
      
    @myvalue = @records.sum(:value)
    @records = @records.order(sort_column + " " + sort_direction).paginate :per_page => params[:per_page], :page => params[:page]
    
    if params[:searchable_type]
      @filter = Artist.find(params[:artist_id])
    end
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
  end

  def create
    @record = Record.new(params[:record])

    respond_to do |format|
      if @record.save
        flash[:notice] = 'Record was successfully created.'
        format.html { redirect_to(@record) }
        format.xml  { render :xml => @record, :status => :created, :location => @record }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @record.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @record = Record.find(params[:id])
    respond_to do |format|
      if @record.update_attributes(params[:record])
        flash[:notice] = 'Record was successfully updated.'
        format.html { redirect_to(@record) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @record.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @record = Record.find(params[:id])
    @record.destroy
  end
  
  private
  
  def sort_column
    params[:sort] || "updated_at"
  end
  
  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
  end
  

end
