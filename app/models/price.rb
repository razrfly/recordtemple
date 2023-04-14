# == Schema Information
#
# Table name: prices
#
#  id               :integer          not null, primary key
#  cached_artist    :string(255)
#  cached_label     :string(255)
#  detail           :string(255)
#  footnote         :text
#  media_type       :string(255)
#  price_high       :integer
#  price_low        :integer
#  yearbegin        :integer
#  yearend          :integer
#  created_at       :datetime
#  updated_at       :datetime
#  artist_id        :integer
#  label_id         :integer
#  record_format_id :integer
#  user_id          :integer
#
# Indexes
#
#  index_prices_on_cached_artist_trigram  (cached_artist) USING gin
#  index_prices_on_cached_label_trigram   (cached_label) USING gin
#  index_prices_on_detail_trigram         (detail) USING gin
#  index_prices_on_media_type_trigram     (media_type) USING gin
#
# Foreign Keys
#
#  fk_rails_...  (artist_id => artists.id)
#  fk_rails_...  (label_id => labels.id)
#  fk_rails_...  (record_format_id => record_formats.id)
#  fk_rails_...  (user_id => users.id)
#
class Price < ApplicationRecord
  belongs_to :artist
  belongs_to :label
  belongs_to :record_format
  belongs_to :user

  has_many :records

  delegate :name, to: :artist, prefix: true, allow_nil: true
  delegate :name, to: :label, prefix: true, allow_nil: true
  delegate :name, to: :record_format, prefix: true, allow_nil: true

  def title
    [artist_name, label_name, record_format_name, detail].compact.join(' - ')
  end
end
