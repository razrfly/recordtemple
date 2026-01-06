class DiscoveryController < ApplicationController
  # All records are scoped to user_id: 1 (greg2man@gmail.com)
  COLLECTION_USER_ID = 1
  WALL_SIZE = 60  # Fixed wall size, no infinite scroll

  def index
    add_breadcrumb("Discover")

    # Shuffle Machine - preload 4 random records
    @shuffle_records = Record.random_with_media(COLLECTION_USER_ID)
                             .includes(:artist, :label)
                             .with_attached_images
                             .limit(4)

    # Daily Gems - records with images AND songs, refreshed daily
    @daily_gems = Record.daily_gems(COLLECTION_USER_ID, 10)
                        .includes(:artist, :label, :genre, :record_format, :price)
                        .with_attached_images

    # Cover Wall - fixed size, deterministic daily ordering
    @wall_records = Record.cover_wall(COLLECTION_USER_ID, WALL_SIZE)
                          .includes(:artist, :label)
                          .with_attached_images

    # Stats for display
    @total_with_images = base_scope.has_images.count
    @total_with_songs = base_scope.has_songs.count
  end

  # Turbo Stream endpoint for shuffle machine - returns 4 random records
  def shuffle
    @shuffle_records = Record.random_with_media(COLLECTION_USER_ID)
                             .includes(:artist, :label)
                             .with_attached_images
                             .limit(4)

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to discovery_path }
    end
  end

  # Turbo Stream endpoint for quick view modal
  def quick_view
    @record = base_scope.includes(:artist, :label, :genre, :record_format, :price)
                        .with_attached_images
                        .find(params[:id])

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to record_path(@record) }
    end
  end

  private

  def base_scope
    Record.where(user_id: COLLECTION_USER_ID)
  end
end
