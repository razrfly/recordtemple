class Admin::ArtistsController < Admin::AdminController
  def index
    @artists = Artist.all
  end
end
