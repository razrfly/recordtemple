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
  belongs_to :genre
  belongs_to :price
  belongs_to :user
  belongs_to :record_format
  belongs_to :artist
  belongs_to :label

  enum condition: { mint: 1, near_mint: 2, very_good_plusplus: 3,
    very_good_plus: 4, very_good: 5, good: 6, poor: 7 }

  has_many_attached :images
  has_many_attached :songs

  delegate :name, to: :artist, prefix: true, allow_nil: true
  delegate :name, to: :label, prefix: true, allow_nil: true
  delegate :name, to: :record_format, prefix: true, allow_nil: true

  delegate :price_high, :price_low, :yearbegin, :yearend, :detail, :footnote, to: :price, prefix: false, allow_nil: true

  scope :has_images, -> { joins(:images_attachments) }
  scope :has_songs, -> { joins(:songs_attachments) }

  def cover
    images.first unless images.empty?
  end

  def title
    [artist_name, label_name, record_format_name].compact.join(' - ')
  end
  
end
