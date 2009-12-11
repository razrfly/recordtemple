class PricesController < ApplicationController
  
  before_filter :login_required
  
  protect_from_forgery :except => [:auto_complete_for_price_artist,:auto_complete_for_price_label]
  
  def auto_complete_for_price_artist
    @prices = Price.find(:all,
        :select => 'DISTINCT(artist)',
        :conditions => [ 'LOWER(artist) LIKE ?', "#{params[:price][:artist].downcase}%" ],
        :order => 'artist ASC',
        :limit => 8)
      render :partial => 'artists'  
  end
  def auto_complete_for_price_label
    @prices = Price.find(:all,
        :select => 'DISTINCT(label)',
        :conditions => [ 'LOWER(label) LIKE ?', "#{params[:price][:label].downcase}%" ],
        :order => 'label ASC',
        :limit => 8)
      render :partial => 'labels'
  end

  def index
    if params[:price] and params[:id] = "" and params[:hidden][:created_by] == ""
      @prices = Price.find(:all, :conditions => ['artist LIKE ? and label LIKE ? and format LIKE ? and detail LIKE ?',
         "%#{params[:price][:artist]}%", "%#{params[:price][:label]}%", "%#{params[:type]}%", "%#{params[:detail]}%"],
         :limit => "#{params[:num_of_result]}")
      @prices_raw = Price.count(:id, :conditions => ['artist LIKE ? and label LIKE ? and format LIKE ? and detail LIKE ?',
          "%#{params[:price][:artist]}%", "%#{params[:price][:label]}%", "%#{params[:type]}%", "%#{params[:detail]}%"])      
      respond_to do |format|
        format.html
        format.js
      end
    #elsif params[:id]
     # @prices = Price.count(params[:id], :limit => '10')
      #@prices_raw = Price.find(params[:id])
    elsif params[:hidden]  
      @prices = Price.find(:all, :conditions => ['created_by = ?', params[:hidden][:created_by] ])
      @prices_raw = Price.count(:all, :conditions => ['created_by = ?', params[:hidden][:created_by] ])
    else
      #@prices = Price.find(:all)
      @prices = Price.find(:all, :limit => '10')
      @prices_raw = Price.count
      respond_to do |format|
        format.html # index.html.erb
        format.xml  { render :xml => @records }
      end
    end
  end
  def show
    @price = Price.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @price }
    end
  end
  
  # GET /prices/new
  # GET /prices/new.xml
  def new
    @price = Price.new
    #@bubble = Bubble.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @price }
    end
  end

  # GET /records/1/edit
  def edit
    @price = Price.find(params[:id])
    #@record.mugshots.build
  end

  # POST /prices
  # POST /prices.xml
  def create
    @price = Price.new(params[:price])
    @bubble = @price.bubbles.build(params[:bubble])

    respond_to do |format|
      if @price.save
        flash[:notice] = 'Price was successfully created.'
        format.html { redirect_to(@price) }
        format.xml  { render :xml => @price, :status => :created, :location => @price }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @price.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  # PUT /records/1
  # PUT /records/1.xml
  def update
    @price = Price.find(params[:id])

    
    respond_to do |format|
      if @price.update_attributes(params[:price])
        flash[:notice] = 'Price was successfully updated.'
        format.html { redirect_to(@price) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @price.errors, :status => :unprocessable_entity }
      end
    end
  end  
  
  # DELETE /prices/1
  # DELETE /prices/1.xml
  def destroy
    @price = Price.find(params[:id])
    @price.destroy

    respond_to do |format|
      flash[:notice] = 'Price guide price was killed in battle.'
      format.html { redirect_to(prices_url) }
      format.xml  { head :ok }
    end
  end
    

end
