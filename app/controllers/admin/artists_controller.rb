class Admin::ArtistsController < Admin::AdminController
  before_action :set_artist, :only => [:show, :edit, :update, :destroy]

  def index
    respond_to do |format|
      format.html
      format.json { render json: ArtistsDatatable.new(view_context) }
    end
  end

  def show
  end

  def new
    @artist = Artist.new
  end

  def edit
  end

  def create
    @artist = Artist.new(artist_params)

    if @artist.save
      redirect_to admin_artists_path, :notice => "Artist was successfully created."
    else
      render :new
    end
  end

  def update
    if @artist.update_attributes(artist_params)
      redirect_to admin_artists_path, :notice => "Artist was successfully updated."
    else
      render :edit
    end
  end

  def destroy
    @artist.destroy
    redirect_to admin_artists_path, :notice => "Artist was successfully deleted."
  end

  private
    def set_artist
      @artist = Artist.find(params[:id])
    end

    def artist_params
      params.require(:artist).permit(:name, :freebase_id)
    end
end
