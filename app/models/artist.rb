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

  def cover
    if records.has_images.present?
      records.has_images.first.cover
    end
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[name]
  end

  def self.ransortable_attributes(auth_object = nil)
    %w[name]
  end
end
