# == Schema Information
#
# Table name: discogs_releases
#
#  id              :bigint           not null, primary key
#  discogs_id      :bigint           not null
#  master_id       :bigint
#  title           :string           not null
#  year            :integer
#  country         :string
#  catno           :string
#  artists         :jsonb            default([])
#  labels          :jsonb            default([])
#  formats         :jsonb            default([])
#  tracklist       :jsonb            default([])
#  genres          :jsonb            default([])
#  styles          :jsonb            default([])
#  images          :jsonb            default([])
#  community_have  :integer
#  community_want  :integer
#  lowest_price    :decimal(10, 2)
#  raw_response    :jsonb            default({})
#  fetched_at      :datetime         not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_discogs_releases_on_artists     (artists) USING gin
#  index_discogs_releases_on_catno       (catno)
#  index_discogs_releases_on_discogs_id  (discogs_id) UNIQUE
#  index_discogs_releases_on_master_id   (master_id)
#
class DiscogsRelease < ApplicationRecord
  has_many :records

  validates :discogs_id, presence: true, uniqueness: true
  validates :title, presence: true
  validates :fetched_at, presence: true

  # Convenience accessors for JSONB data
  def primary_artist
    artists&.first&.dig("name")
  end

  def primary_label
    labels&.first&.dig("name")
  end

  def primary_catno
    labels&.first&.dig("catno") || catno
  end

  def format_description
    formats&.first&.dig("descriptions")&.join(", ")
  end

  def format_name
    formats&.first&.dig("name")
  end

  def cover_image_url
    images&.find { |i| i["type"] == "primary" }&.dig("uri") ||
      images&.first&.dig("uri")
  end

  def discogs_url
    "https://www.discogs.com/release/#{discogs_id}"
  end

  def master_url
    return nil unless master_id
    "https://www.discogs.com/master/#{master_id}"
  end

  # Community popularity score (simple ratio)
  def popularity_ratio
    return nil unless community_have&.positive?
    community_want.to_f / community_have
  end
end
