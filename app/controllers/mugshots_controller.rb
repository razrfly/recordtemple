class MugshotsController < ApplicationController
  def destroy
    @mugshot = Mugshot.find(params[:id])
    @mugshot.destroy
    
    respond_to do |format|
      flash[:notice] = 'Attached photo was killed in battle.'
      format.html { redirect_to :back }
      format.xml  { head :ok }
    end
  end

end
