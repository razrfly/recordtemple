class PricesController < ApplicationController
  
  before_filter :authenticate_user!
  
  autocomplete :artist, :name
  autocomplete :label, :name
  
  #protect_from_forgery :except => [:autocomplete_artist_name, :autocomplete_label_name]

  def index
    if params[:name]
      @prices = Price.where("LOWER(cached_artist) LIKE ? AND LOWER(cached_label) LIKE ? AND LOWER(media_type) LIKE ?", "#{params[:name].downcase}%", "#{params[:label].downcase}%", "%#{params[:media_type].downcase}%").paginate :page => params[:page], :per_page => params[:per_page]
    end
  end
  
  def show
    @price = Price.find(params[:id])

  end
  
  def new
    @price = Price.new

  end

  def edit
    @price = Price.find(params[:id])
  end

  def create
    @price = Price.new(params[:price])

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
