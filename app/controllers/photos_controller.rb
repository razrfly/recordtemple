class PhotosController < ApplicationController
  def destroy
    @photo = Photo.find(params[:id])
    @photo.destroy
    
    respond_to do |format|
      flash[:notice] = 'Attached photo was killed in battle.'
      format.html { redirect_to :back }
      format.xml  { head :ok }
    end
  end

end
