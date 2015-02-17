class Admin::SongsController < Admin::AdminController

  # PUT /index
  def index
    @search = Song.ransack(params[:q])
    @songs = @search.result
    respond_to do |format|
      format.json {
        render json: @songs.to_json(:only => [:title, :id]) }
    end
  end
end