class Admin::ArtistsController < Admin::AdminController
  before_action :set_artist, only: [:show, :edit, :update, :destroy]

  def index
    @search = Artist.ransack(params[:q])
    @artists = @search.result.page(params[:page])

    respond_to do |format|
      format.html
      format.json { render json: @artists.to_json(only: [:name, :id]) }
    end
  end

  def show
    @records = @artist.records.where(user: current_user).page(params[:records_page])
    @prices = @artist.prices.page(params[:prices_page])
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
