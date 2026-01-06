# == Schema Information
#
# Table name: labels
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  slug       :string(255)
#  created_at :datetime
#  updated_at :datetime
#
# Indexes
#
#  index_labels_on_name  (name) UNIQUE
#  index_labels_on_slug  (slug) UNIQUE
#  labels_fts_idx        (to_tsvector('english'::regconfig, (COALESCE(name, ''::character varying))::text)) USING gin
#
class Label < ApplicationRecord
  extend FriendlyId

  has_many :prices
  has_many :records

  friendly_id :name, use: [:slugged, :finders]

  scope :with_records, -> { joins(:records).distinct }
  scope :with_records_and_images, -> { joins(records: :images_attachments).distinct }

  # Discovery curation scopes - all require user_id parameter for scoping
  # Most collected: labels with the most records
  scope :most_collected, ->(user_id, limit = 12) {
    joins(:records)
      .where(records: { user_id: user_id })
      .group("labels.id")
      .select("labels.*, COUNT(records.id) as records_count")
      .order("records_count DESC")
      .limit(limit)
  }

  # Recently added: labels with most recently added records to the collection
  scope :recently_added, ->(user_id, limit = 12) {
    joins(:records)
      .where(records: { user_id: user_id })
      .group("labels.id")
      .select("labels.*, COUNT(records.id) as records_count, MAX(records.created_at) as latest_record_at")
      .order("latest_record_at DESC")
      .limit(limit)
  }

  # Hidden gems: labels with 2-5 records (enough to be interesting, but not heavily collected)
  # Uses daily seed for deterministic pseudo-random ordering (consistent within a day, changes daily)
  scope :hidden_gems, ->(user_id, limit = 12) {
    daily_seed = Date.current.to_s
    joins(:records)
      .where(records: { user_id: user_id })
      .group("labels.id")
      .select("labels.*, COUNT(records.id) as records_count")
      .having("COUNT(records.id) BETWEEN 2 AND 5")
      .order(Arel.sql("MD5(CONCAT(labels.id::text, '#{daily_seed}'))"))
      .limit(limit)
  }

  # Returns the first record cover for this label (scoped to user)
  def cover(user_id = nil)
    scope = user_id ? records.where(user_id: user_id) : records
    scope.has_images.first&.cover
  end

  # Returns up to N sample covers for collage display (scoped to user)
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
