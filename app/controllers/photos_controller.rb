class PhotosController < ApplicationController
  
  #skip_before_filter :verify_authenticity_token, :only => [ :create ]
  
  def index
    @record = Record.find(params[:record_id])
    @photos = @record.photos.all(:order => :position)
  end
  
  def create
    @record = Record.find(params[:record_id]) 
    params[:Filedata].content_type = MIME::Types.type_for(params[:Filedata].original_filename).to_s    
    @photo = Photo.new(:record_id => @record.id, :data => params[:Filedata])

    if @photo.save
        render :json => { 'status' => 'success' }
    else
        render :json => { 'status' => 'error' }     
    end
  end
  
  def destroy
    @photo = Photo.find(params[:id])
    @photo.destroy
    
    respond_to do |format|
      flash[:notice] = 'Attached photo was killed in battle.'
      format.html { redirect_to :back }
      format.xml  { head :ok }
    end
  end
  
  def sort
    params[:photo].each_with_index do |id,index|
      Photo.update_all(['position=?', index+1], ['id=?', id])
    end
    render :nothing => true
  end

end
