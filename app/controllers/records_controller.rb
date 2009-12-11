class RecordsController < ApplicationController
  # GET /records
  # GET /records.xml
  
before_filter :login_required

  def index
      #@records = Record.all
      @records = Record.search(params[:artist], params[:page], current_user.login)
      #calculations
      #@myvalue = Record.values(params[:artist], current_user.login)
      #@hisvalue = Record.osbourne(params[:artist], current_user.login)
      #@chart_months = Record.chart_months
      #@chart_months_data = Record.chart_months_data
      
      respond_to do |format|
        format.html # index.html.erb
        format.xml  { render :xml => @records }
      end

  end

  # GET /records/1
  # GET /records/1.xml
  def show
    @record = Record.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @record }
    end
  end

  # GET /records/new
  # GET /records/new.xml
  def new
    @record = Record.new

    #@mugshot = Mugshot.new
    @record.photos.build

    if params[:id]
      @price = Price.find(params[:id])
    end
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @record }
    end
  end

  # GET /records/1/edit
  def edit
    @record = Record.find(params[:id])
    #@record.photos.build
  end

  # POST /records
  # POST /records.xml
  def create
    @record = Record.new(params[:record])

    #@mugshot = Mugshot.new(:uploaded_data => params[:mugshot_file])
    #@mugshot.save 
    
    #@service = RecordService.new(@record, @mugshot) 

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


  # PUT /records/1
  # PUT /records/1.xml
  def update
    @record = Record.find(params[:id])
    #@mugshot = @record.mugshot 
    #@record.mugshots.build
    #@service = RecordService.new(@record, @mugshot) 
    

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

  # DELETE /records/1
  # DELETE /records/1.xml
  def destroy
    @record = Record.find(params[:id])
    @record.destroy


    respond_to do |format|
      format.html { redirect_to(records_url) }
      format.xml  { head :ok }
    end
  end

end
