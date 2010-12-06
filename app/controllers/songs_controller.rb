class SongsController < ApplicationController
  
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
