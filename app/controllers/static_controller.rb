class StaticController < ApplicationController
  # All records are scoped to user_id: 1 (greg2man@gmail.com)
  COLLECTION_USER_ID = 1

  def index
    # Shuffle Machine - 4 random records with images
    @shuffle_records = Record.random_with_media(COLLECTION_USER_ID)
                             .includes(:artist, :label)
                             .with_attached_images
                             .limit(4)

    # Daily Gems - records with images AND songs, refreshed daily
    @daily_gems = Record.daily_gems(COLLECTION_USER_ID, 8)
                        .includes(:artist, :label)
                        .with_attached_images
                        .with_attached_songs

    # Cover Wall - deterministic daily selection
    @wall_records = Record.cover_wall(COLLECTION_USER_ID, 30)
                          .includes(:artist, :label)
                          .with_attached_images
                          .with_attached_songs

    # Artist Discovery - three categories for tabbed carousel
    @top_artists = Artist.most_collected(COLLECTION_USER_ID, 12)
    @random_artists = Artist.joins(:records)
                            .where(records: { user_id: COLLECTION_USER_ID })
                            .group("artists.id")
                            .select("artists.*, COUNT(records.id) as records_count")
                            .order(Arel.sql("RANDOM()"))
                            .limit(12)
    @hidden_gem_artists = Artist.hidden_gems(COLLECTION_USER_ID, 12)

    # Preload covers for N+1 optimization
    @artist_covers = preload_artist_covers(@top_artists + @random_artists + @hidden_gem_artists)

    # Collection stats for hero section
    @stats = {
      records: base_scope.count,
      artists: Artist.joins(:records).where(records: { user_id: COLLECTION_USER_ID }).distinct.count,
      labels: Label.joins(:records).where(records: { user_id: COLLECTION_USER_ID }).distinct.count,
      with_audio: base_scope.has_songs.count
    }
  end

  def members_only
  end

  private

  def base_scope
    Record.where(user_id: COLLECTION_USER_ID)
  end

  # Batch load covers for all artists to avoid N+1 queries
  def preload_artist_covers(artists)
    artist_ids = artists.map(&:id).uniq
    return {} if artist_ids.empty?

    # Get up to 4 covers per artist for 2x2 collage display
    covers_by_artist = {}
    Record.where(user_id: COLLECTION_USER_ID, artist_id: artist_ids)
          .has_images
          .includes(images_attachments: :blob)
          .group_by(&:artist_id)
          .each do |artist_id, records|
            covers_by_artist[artist_id] = records.first(4).map(&:cover).compact
          end

    covers_by_artist
  end
end
