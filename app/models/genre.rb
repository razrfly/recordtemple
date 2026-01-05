# == Schema Information
#
# Table name: genres
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  slug       :string(255)
#  created_at :datetime
#  updated_at :datetime
#
# Indexes
#
#  index_genres_on_slug  (slug) UNIQUE
#
class Genre < ApplicationRecord
  extend FriendlyId

  has_many :records
  has_many :artists, through: :records
  has_many :labels, through: :records

  friendly_id :name, use: [:slugged, :finders]

  scope :with_records, -> { joins(:records).distinct }
  scope :with_records_and_images, -> { joins(records: :images_attachments).distinct }

  # Discovery curation scopes - all require user_id parameter for scoping
  # Most collected: genres with the most records
  scope :most_collected, ->(user_id, limit = 12) {
    joins(:records)
      .where(records: { user_id: user_id })
      .group("genres.id")
      .select("genres.*, COUNT(records.id) as records_count")
      .order("records_count DESC")
      .limit(limit)
  }

  # Recently added: genres with most recently added records to the collection
  scope :recently_added, ->(user_id, limit = 12) {
    joins(:records)
      .where(records: { user_id: user_id })
      .group("genres.id")
      .select("genres.*, COUNT(records.id) as records_count, MAX(records.created_at) as latest_record_at")
      .order("latest_record_at DESC")
      .limit(limit)
  }

  # Hidden gems: genres with 5-20 records (enough to be interesting, but not dominant)
  # Uses daily seed for deterministic pseudo-random ordering (consistent within a day, changes daily)
  scope :hidden_gems, ->(user_id, limit = 12) {
    daily_seed = Date.current.to_s
    joins(:records)
      .where(records: { user_id: user_id })
      .group("genres.id")
      .select("genres.*, COUNT(records.id) as records_count")
      .having("COUNT(records.id) BETWEEN 5 AND 20")
      .order(Arel.sql(sanitize_sql_for_order(["MD5(CONCAT(genres.id::text, ?))", daily_seed])))
      .limit(limit)
  }

  # Returns the first record cover for this genre (scoped to user)
  def cover(user_id = nil)
    scope = user_id ? records.where(user_id: user_id) : records
    scope.has_images.first&.cover
  end

  # Returns up to N sample covers for collage display
  def sample_covers(limit = 4, user_id = nil)
    scope = user_id ? records.where(user_id: user_id) : records
    scope.has_images.limit(limit).map(&:cover)
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[name]
  end

  def self.ransortable_attributes(auth_object = nil)
    %w[name]
  end
end
