# == Schema Information
#
# Table name: records
#
#  id               :integer          not null, primary key
#  cached_artist    :string(255)
#  cached_label     :string(255)
#  comment          :text
#  condition        :integer
#  value            :integer
#  created_at       :datetime
#  updated_at       :datetime
#  artist_id        :integer
#  genre_id         :integer
#  identifier_id    :integer
#  label_id         :integer
#  price_id         :integer
#  record_format_id :integer
#  user_id          :integer
#
# Indexes
#
#  index_records_on_artist_id         (artist_id)
#  index_records_on_genre_id          (genre_id)
#  index_records_on_label_id          (label_id)
#  index_records_on_price_id          (price_id)
#  index_records_on_record_format_id  (record_format_id)
#  index_records_on_user_id           (user_id)
#  records_fts_idx                    (to_tsvector('english'::regconfig, COALESCE(comment, ''::text))) USING gin
#
# Foreign Keys
#
#  fk_rails_...  (artist_id => artists.id)
#  fk_rails_...  (genre_id => genres.id)
#  fk_rails_...  (label_id => labels.id)
#  fk_rails_...  (price_id => prices.id)
#  fk_rails_...  (record_format_id => record_formats.id)
#  fk_rails_...  (user_id => users.id)
#
class Record < ApplicationRecord
  include PgSearch::Model

  belongs_to :genre
  belongs_to :price, optional: true
  belongs_to :user
  belongs_to :record_format
  belongs_to :artist
  belongs_to :label

  # Wide-net search using pre-computed tsvector column for performance
  # The searchable column is populated by a database trigger and includes:
  # - Weight A: cached_artist, artist.name
  # - Weight B: cached_label, label.name
  # - Weight C: genre.name, record_format.name, comment
  # - Weight D: price.detail, price.footnote, price.yearbegin, price.yearend
  pg_search_scope :wide_search,
    against: :cached_artist, # Required but not used when tsvector_column is set
    using: {
      tsearch: {
        prefix: true,
        dictionary: "english",
        any_word: true,
        tsvector_column: "searchable"
      },
      trigram: {
        only: [ :cached_artist, :cached_label ],
        threshold: 0.3
      }
    },
    ignoring: :accents

  # Legacy Photo/Song models - kept for backwards compatible URLs
  # Actual files are served via Active Storage (images/songs attachments)
  has_many :photos
  has_many :legacy_songs, class_name: "Song", foreign_key: "record_id"

  enum :condition, { mint: 1, "near mint": 2, "vg++": 3,
    "vg+": 4, "very good": 5, good: 6, poor: 7 }

  has_many_attached :images
  has_many_attached :songs

  validates :condition, presence: true

  # Update popularity score when relevant fields change
  after_commit :schedule_popularity_update, if: :popularity_affecting_change?

  delegate :name, to: :artist, prefix: true, allow_nil: true
  delegate :name, to: :label, prefix: true, allow_nil: true
  delegate :name, to: :record_format, prefix: true, allow_nil: true

  delegate :price_high, :price_low, :yearbegin, :yearend, :detail, :footnote, to: :price, prefix: false, allow_nil: true

  scope :has_images, -> { joins(:images_attachments).distinct }
  scope :has_songs, -> { joins(:songs_attachments).distinct }

  def cover
    images.first unless images.empty?
  end

  def song_titles
    songs.map { |blob| blob.filename.to_s.gsub(/\.mp3$/, '') }
  end

  def title
    [artist_name, label_name, record_format_name, song_titles.join(' - ')].compact.join(' - ')
  end

  # Ransack configuration
  def self.ransackable_attributes(auth_object = nil)
    %w[artist_id label_id genre_id record_format_id condition comment created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[artist label genre record_format]
  end

  def self.ransortable_attributes(auth_object = nil)
    %w[created_at condition popularity_score]
  end

  private

  # Fields that affect popularity score calculation
  POPULARITY_FIELDS = %w[comment price_id identifier_id record_format_id].freeze

  def popularity_affecting_change?
    (previous_changes.keys & POPULARITY_FIELDS).any?
  end

  def schedule_popularity_update
    RecordPopularityJob.perform_later(id)
  end
end
