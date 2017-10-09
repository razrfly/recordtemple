class Price < ActiveRecord::Base

  belongs_to :record_format
  belongs_to :artist
  belongs_to :label
  belongs_to :user
  has_many :records
  has_one :record_type, through: :record_format

  delegate :name, to: :artist, prefix: true, allow_nil: true
  delegate :name, to: :label, prefix: true, allow_nil: true
  delegate :name, to: :record_format, prefix: true, allow_nil: true
  delegate :name, to: :record_type, prefix: true, allow_nil: true

  validates_presence_of :artist_id, :label_id, :record_format_id
end
