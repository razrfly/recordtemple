class SongsController < ApplicationController
  before_action :set_record, only: [:index, :create]

  def index
  end

  def create
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

  private
    def set_record
      @record = Record.find(params[:record_id])
      @songs = @record.songs if params[:action]=='index'
    end
end
