# frozen_string_literal: true

# Concern for batch loading cover images for discovery cards
# Eliminates N+1 queries by preloading covers for collections of artists/labels/genres
module DiscoveryCovers
  extend ActiveSupport::Concern

  VALID_ENTITY_TYPES = %i[artist label genre].freeze

  private

  # Batch load covers for multiple entities (artists, labels, or genres)
  # Returns a hash: { entity_id => [cover1, cover2, cover3, cover4] }
  #
  # @param entities [ActiveRecord::Relation] Collection of Artist, Label, or Genre
  # @param entity_type [Symbol] :artist, :label, or :genre
  # @param user_id [Integer] User ID to scope records
  # @param limit [Integer] Max covers per entity (default: 4)
  # @return [Hash<Integer, Array<ActiveStorage::Attachment>>]
  def batch_load_covers(entities, entity_type, user_id, limit: 4)
    return {} if entities.blank?
    validate_entity_type!(entity_type)

    entity_ids = entities.map(&:id)
    foreign_key = "#{entity_type}_id"

    # Use window function to get up to `limit` records with images per entity
    # This is much more efficient than N separate queries
    ranked_records_sql = <<~SQL
      SELECT records.*, ROW_NUMBER() OVER (
        PARTITION BY records.#{foreign_key}
        ORDER BY records.id
      ) as row_num
      FROM records
      INNER JOIN active_storage_attachments
        ON active_storage_attachments.record_type = 'Record'
        AND active_storage_attachments.record_id = records.id
        AND active_storage_attachments.name = 'images'
      WHERE records.#{foreign_key} IN (:entity_ids)
        AND records.user_id = :user_id
    SQL

    # Wrap in subquery to filter by row_num
    records_with_images = Record
      .from("(#{Record.sanitize_sql([ranked_records_sql, entity_ids: entity_ids, user_id: user_id])}) as records")
      .where("row_num <= ?", limit)
      .includes(images_attachments: :blob)

    # Group records by entity and extract sorted cover images
    covers_by_entity = Hash.new { |h, k| h[k] = [] }

    records_with_images.each do |record|
      entity_id = record.send(foreign_key)
      # Get the first image sorted by filename (the "cover")
      cover = record.images.min_by { |img| img.filename.to_s }
      covers_by_entity[entity_id] << cover if cover
    end

    covers_by_entity
  end

  # Preload covers for discovery carousel entities
  # Call this after loading popular/recent/hidden_gem collections
  #
  # @param popular [ActiveRecord::Relation] Popular items collection
  # @param recent [ActiveRecord::Relation] Recent items collection
  # @param hidden_gems [ActiveRecord::Relation] Hidden gems collection
  # @param entity_type [Symbol] :artist, :label, or :genre
  # @param user_id [Integer] User ID to scope records
  # @return [Hash<Integer, Array<ActiveStorage::Attachment>>]
  def preload_discovery_covers(popular:, recent:, hidden_gems:, entity_type:, user_id:)
    # Combine all entities to load covers in one batch
    all_entities = [popular, recent, hidden_gems].flatten.compact.uniq(&:id)
    batch_load_covers(all_entities, entity_type, user_id, limit: 4)
  end

  # Load a single cover for an entity (for show pages)
  # Returns the first image from the first record with images
  #
  # @param entity_id [Integer] ID of the artist, label, or genre
  # @param entity_type [Symbol] :artist, :label, or :genre
  # @param user_id [Integer] User ID to scope records
  # @return [ActiveStorage::Attachment, nil] The cover image or nil
  def load_entity_cover(entity_id, entity_type, user_id)
    validate_entity_type!(entity_type)
    foreign_key = "#{entity_type}_id"

    record = Record
      .joins(:images_attachments)
      .where(foreign_key => entity_id, user_id: user_id)
      .includes(images_attachments: :blob)
      .order(:id)
      .first

    return nil unless record

    record.images.min_by { |img| img.filename.to_s }
  end

  # Validate entity_type to prevent SQL injection
  # @param entity_type [Symbol] Must be :artist, :label, or :genre
  # @raise [ArgumentError] if entity_type is not valid
  def validate_entity_type!(entity_type)
    return if VALID_ENTITY_TYPES.include?(entity_type.to_sym)

    raise ArgumentError, "Invalid entity_type: #{entity_type}. Must be one of: #{VALID_ENTITY_TYPES.join(', ')}"
  end
end
