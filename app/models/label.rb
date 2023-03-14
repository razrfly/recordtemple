# == Schema Information
#
# Table name: labels
#
#  id          :integer          not null, primary key
#  name        :string(255)
#  slug        :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#  freebase_id :string(255)
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

  def cover
    if records.has_images.present?
      records.has_images.first.cover
    end
  end
end
