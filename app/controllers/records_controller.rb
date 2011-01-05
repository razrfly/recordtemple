class RecordsController < ApplicationController

before_filter :authenticate_user!

  def index

    @search = Search.new
    
    @records = Record.scoped
    @records = @records.where(:user_id => current_user.id)
    @records = @records.where(:artist_id => params[:artist_id]) if params[:artist_id]
    @records = @records.where(:label_id => params[:label_id]) if params[:label_id]
    @records = @records.joins(:songs) if params[:mp3]
      
    @myvalue = @records.sum(:value)
    @records = @records.order("updated_at DESC").paginate :per_page => params[:per_page], :page => params[:page]
      

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

    respond_to do |format|
      format.html { redirect_to(records_url) }
      format.xml  { head :ok }
    end
  end

end
