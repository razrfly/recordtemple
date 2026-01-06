class ArtistsController < ApplicationController
  include Pagy::Backend

  # All records are scoped to user_id: 1 (greg2man@gmail.com)
  COLLECTION_USER_ID = 1

  def index
    add_breadcrumb("Artists")

    # Base query for all artists with records
    base_artists = Artist.joins(:records)
                         .where(records: { user_id: COLLECTION_USER_ID })
                         .group("artists.id")
                         .select("artists.*, COUNT(records.id) as records_count")

    # Discovery curation collections for tabs
    @popular_artists = Artist.most_collected(COLLECTION_USER_ID, 12)
    @recent_artists = Artist.recently_added(COLLECTION_USER_ID, 12)
    @hidden_gem_artists = Artist.hidden_gems(COLLECTION_USER_ID, 12)

    # All artists for browsing, optionally filtered by letter
    @current_letter = params[:letter]&.upcase
    artists_query = base_artists.order("artists.name ASC")

    if @current_letter.present?
      if @current_letter == "#"
        # Non-alphabetic (numbers, symbols)
        artists_query = artists_query.where("artists.name !~* '^[A-Za-z]'")
      else
        artists_query = artists_query.where("artists.name ILIKE ?", "#{@current_letter}%")
      end
    end

    @pagy, @artists = pagy(artists_query, items: 30)
    @total_count = base_artists.length

    # Get available letters for A-Z navigation
    @available_letters = Artist.joins(:records)
                               .where(records: { user_id: COLLECTION_USER_ID })
                               .distinct
                               .pluck(Arel.sql("UPPER(LEFT(artists.name, 1))"))
                               .sort
  end

  def random
    # Get a random artist that has records in the collection
    random_artist = Artist.joins(:records)
                          .where(records: { user_id: COLLECTION_USER_ID })
                          .order(Arel.sql("RANDOM()"))
                          .first

    if random_artist
      redirect_to artist_path(random_artist)
    else
      redirect_to artists_path, alert: "No artists found in the collection."
    end
  end

  def show
    @artist = Artist.friendly.find(params[:id])

    add_breadcrumb("Artists", artists_path)
    add_breadcrumb(@artist.name)

    # Get records for this artist (scoped to user's collection)
    @q = records_scope.ransack(params[:q])
    @q.sorts = "popularity_score desc" if @q.sorts.empty?

    records = @q.result(distinct: true)
                .includes(:artist, :label, :genre, :record_format, :price)
                .with_attached_images

    @pagy, @records = pagy(records)
    @total_count = records_scope.count
    @filtered_count = @q.result(distinct: true).count

    # Stats for the hero section
    @labels_count = records_scope.distinct.count(:label_id)
    @genres = records_scope.joins(:genre)
                           .group("genres.name")
                           .order(Arel.sql("COUNT(*) DESC"))
                           .limit(3)
                           .pluck(Arel.sql("genres.name"))
  end

  private

  def records_scope
    Record.where(user_id: COLLECTION_USER_ID, artist_id: @artist.id)
  end
end
