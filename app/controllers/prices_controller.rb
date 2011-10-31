class PricesController < ApplicationController
  
  before_filter :authenticate_user!
  
  #protect_from_forgery :except => [:auto_complete_for_price_artist,:auto_complete_for_price_label]
  
  #def auto_complete_for_price_artist
  #  @prices = Price.find(:all,
  #      :select => 'DISTINCT(artist)',
  #      :conditions => [ 'LOWER(artist) LIKE ?', "%#{params[:price][:artist].downcase}%" ],
  #      :order => 'artist ASC',
  #      :limit => 8)
  #    render :partial => 'artists'  
  #end
  #def auto_complete_for_price_label
  #  @prices = Price.find(:all,
  #      :select => 'DISTINCT(label)',
  #      :conditions => [ 'LOWER(label) LIKE ?', "#{params[:price][:label].downcase}%" ],
  #      :order => 'label ASC',
  #      :limit => 8)
  #    render :partial => 'labels'
  #end

  def index
    if params[:name]
      @prices = Price.where("LOWER(cache_artist) LIKE ? AND LOWER(cache_label) LIKE ? AND LOWER(media_type) LIKE ?", "#{params[:name].downcase}%", "#{params[:label].downcase}%", "%#{params[:media_type].downcase}%").paginate :page => params[:page], :per_page => params[:per_page]
      #@prices = Price.where("LOWER(artist) LIKE ? AND LOWER(label) LIKE ?", "#{params[:artist].downcase}%", "#{params[:label].downcase}%")
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
