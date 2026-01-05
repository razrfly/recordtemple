# == Schema Information
#
# Table name: artists
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  slug       :string(255)
#  created_at :datetime
#  updated_at :datetime
#
# Indexes
#
#  artists_fts_idx        (to_tsvector('english'::regconfig, (COALESCE(name, ''::character varying))::text)) USING gin
#  index_artists_on_name  (name) UNIQUE
#  index_artists_on_slug  (slug) UNIQUE
#
class Artist < ApplicationRecord
  extend FriendlyId

  has_many :prices
  has_many :records
  has_many :genres, through: :records
  has_many :labels, through: :records

  friendly_id :name, use: [:slugged, :finders]

  scope :with_records, -> { joins(:records).distinct }
  scope :with_records_and_images, -> { joins(records: :images_attachments).distinct }

  # Discovery curation scopes - all require user_id parameter for scoping
  # Most collected: artists with the most records
  scope :most_collected, ->(user_id, limit = 12) {
    joins(:records)
      .where(records: { user_id: user_id })
      .group("artists.id")
      .select("artists.*, COUNT(records.id) as records_count")
      .order("records_count DESC")
      .limit(limit)
  }

  # Recently added: artists with most recently added records to the collection
  scope :recently_added, ->(user_id, limit = 12) {
    joins(:records)
      .where(records: { user_id: user_id })
      .group("artists.id")
      .select("artists.*, COUNT(records.id) as records_count, MAX(records.created_at) as latest_record_at")
      .order("latest_record_at DESC")
      .limit(limit)
  }

  # Hidden gems: artists with 2-5 records (enough to be interesting, but not heavily collected)
  # Uses daily seed for deterministic pseudo-random ordering (consistent within a day, changes daily)
  scope :hidden_gems, ->(user_id, limit = 12) {
    daily_seed = Date.current.to_s
    joins(:records)
      .where(records: { user_id: user_id })
      .group("artists.id")
      .select("artists.*, COUNT(records.id) as records_count")
      .having("COUNT(records.id) BETWEEN 2 AND 5")
      .order(Arel.sql("MD5(CONCAT(artists.id::text, '#{daily_seed}'))"))
      .limit(limit)
  }

  def cover
    if records.has_images.present?
      records.has_images.first.cover
    end
  end

  # Returns up to 4 sample covers for collage display
  def sample_covers(limit = 4)
    records.has_images.limit(limit).map(&:cover)
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[name]
  end

  def self.ransortable_attributes(auth_object = nil)
    %w[name]
  end
end
