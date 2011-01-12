class SongsController < ApplicationController
  
  skip_before_filter :verify_authenticity_token, :only => [ :create ]
  
  def index
    @record = Record.find(params[:record_id])
    @songs = @record.songs
  end
  
  def create
    @record = Record.find(params[:record_id]) 
    params[:Filedata].content_type = MIME::Types.type_for(params[:Filedata].original_filename).to_s    
    @song = Song.new(:record_id => @record.id, :mp3 => params[:Filedata])

    if @song.save
        render :json => { 'status' => 'success' }
    else
        render :json => { 'status' => 'error' }     
    end
  end
  
  def destroy
    @song = Song.find(params[:id])
    @song.destroy
    
    respond_to do |format|
      flash[:notice] = 'Attached song was killed in battle.'
      format.html { redirect_to :back }
      format.xml  { head :ok }
    end
  end

end
