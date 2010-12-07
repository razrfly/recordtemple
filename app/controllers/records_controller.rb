class RecordsController < ApplicationController

before_filter :authenticate_user!

  def index
      #@records = Record.all
      #@records = Record.search(params[:artist], params[:page], current_user)
      @myvalue = Record.sum('value', :conditions => [ 'user_id = ?', current_user.id ])
      @hisvalue = Record.sum('pricehigh', :joins => :price, :conditions => [ 'user_id = ?', current_user.id ])
      if params[:artist]
        @records = Record.search(params[:artist], params[:page], current_user)
      else
        @records = Record.search(params[:artist], params[:page], current_user)
      end
      
      respond_to do |format|
        format.html # index.html.erb
        format.xml  { render :xml => @records }
      end

  end

  def show
    @record = Record.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @record }
    end
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
