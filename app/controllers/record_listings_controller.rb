class RecordListingsController < ApplicationController
  def index
    @record_listings = RecordListing.all
  end
  
  def show
    @record_listing = RecordListing.find(params[:id])
  end
  
  def new
    @record = Record.find(params[:record_id])
    @record_listing = RecordListing.new
  end
  
  def create
    @record = Record.find(params[:record_id])
    @record_listing = RecordListing.new(params[:record_listing])
    if @record_listing.listing_type = "Tumblr"
      tumblr = current_user.user_accounts.find_by_provider("Tumblr")
      if tumblr
        if params[:record_listing][:tumblr_type] == "photo"
          doc = { :type => "photo", 
                  :source => @record.photos.first.data.url,
                  :"click-through-url" => url_for(record_url(@record)), 
                  :caption => params[:record_listing][:body],
                  :title => params[:record_listing][:title] }
        elsif params[:record_listing][:tumblr_type] == "audio"
          doc = { :type => "audio", 
                  :description => params[:record_listing][:body],
                  :"externally-hosted-url" => @record.songs.first.panda_url }
        else
          doc = { :type => "regular", 
                  :title => params[:record_listing][:title],
                  :description => params[:record_listing][:body] }
        end
        doc = { :state => "published", :tags => params[:record_listing][:tags] }.merge(doc)
        
        request = Tumblr.new(tumblr.key,tumblr.secret).post(doc)
        request.perform do |response|
          if response.success?
            @record_listing.external_id = response.body
          else
            flash[:warning] = "Something went wrong: #{response.code} #{response.message}"
          end
        end
      end
    end
    if @record_listing.save
      flash[:notice] = "Successfully created record listing."
      redirect_to @record
    else
      render :action => 'new'
    end
  end
  
  def edit
    @record_listing = RecordListing.find(params[:id])
  end
  
  def update
    @record_listing = RecordListing.find(params[:id])
    if @record_listing.update_attributes(params[:record_listing])
      flash[:notice] = "Successfully updated record listing."
      redirect_to @record_listing
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @record_listing = RecordListing.find(params[:id])
    @record_listing.destroy
    flash[:notice] = "Successfully destroyed record listing."
    redirect_to record_listings_url
  end
end
