class GenresController < ApplicationController
  include Pagy::Backend
  include DiscoveryCovers

  # All records are scoped to user_id: 1 (greg2man@gmail.com)
  COLLECTION_USER_ID = 1

  def index
    add_breadcrumb("Genres")

    # Base query for all genres with records
    base_genres = Genre.joins(:records)
                       .where(records: { user_id: COLLECTION_USER_ID })
                       .group("genres.id")
                       .select("genres.*, COUNT(records.id) as records_count")

    # Discovery curation collections for tabs (no hidden gems for genres - doesn't make sense conceptually)
    @popular_genres = Genre.most_collected(COLLECTION_USER_ID, 12)
    @recent_genres = Genre.recently_added(COLLECTION_USER_ID, 12)

    # All genres for browsing, optionally filtered by letter
    @current_letter = params[:letter]&.upcase
    genres_query = base_genres.order("genres.name ASC")

    if @current_letter.present?
      if @current_letter == "#"
        # Non-alphabetic (numbers, symbols)
        genres_query = genres_query.where("genres.name !~* '^[A-Za-z]'")
      else
        genres_query = genres_query.where("genres.name ILIKE ?", "#{@current_letter}%")
      end
    end

    @pagy, @genres = pagy(genres_query, items: 30)
    @total_count = Genre.joins(:records)
                        .where(records: { user_id: COLLECTION_USER_ID })
                        .distinct
                        .count

    # Get available letters for A-Z navigation
    @available_letters = Genre.joins(:records)
                              .where(records: { user_id: COLLECTION_USER_ID })
                              .distinct
                              .pluck(Arel.sql("UPPER(LEFT(genres.name, 1))"))
                              .sort

    # Preload covers for all genres (carousel + grid) to eliminate N+1 queries
    all_display_genres = [@popular_genres, @recent_genres, @genres].flatten.compact.uniq(&:id)
    @preloaded_covers = batch_load_covers(all_display_genres, :genre, COLLECTION_USER_ID, limit: 4)
  end

  def random
    # Get a random genre that has records in the collection
    random_genre = Genre.joins(:records)
                        .where(records: { user_id: COLLECTION_USER_ID })
                        .order(Arel.sql("RANDOM()"))
                        .first

    if random_genre
      redirect_to genre_path(random_genre)
    else
      redirect_to genres_path, alert: "No genres found in the collection."
    end
  end

  def show
    @genre = Genre.friendly.find(params[:id])

    add_breadcrumb("Genres", genres_path)
    add_breadcrumb(@genre.name)

    # Preload cover image to avoid N+1 query
    @cover = load_entity_cover(@genre.id, :genre, COLLECTION_USER_ID)

    # Get records for this genre (scoped to user's collection)
    @q = records_scope.ransack(params[:q])
    @q.sorts = "popularity_score desc" if @q.sorts.empty?

    records = @q.result(distinct: true)
                .includes(:artist, :label, :genre, :record_format, :price)
                .with_attached_images
                .with_attached_songs

    @pagy, @records = pagy(records)
    @total_count = records_scope.count
    @filtered_count = @q.result(distinct: true).count

    # Stats for the hero section
    @artists_count = records_scope.distinct.count(:artist_id)
    @labels_count = records_scope.distinct.count(:label_id)
    @top_artists = records_scope.joins(:artist)
                                .group("artists.name")
                                .order(Arel.sql("COUNT(*) DESC"))
                                .limit(5)
                                .pluck(Arel.sql("artists.name"))
  end

  private

  def records_scope
    Record.where(user_id: COLLECTION_USER_ID, genre_id: @genre.id)
  end
end
