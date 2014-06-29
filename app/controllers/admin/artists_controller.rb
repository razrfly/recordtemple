class Admin::ArtistsController < Admin::AdminController
  def index
    @artists = Artist.all.limit(1000)
  end
end
