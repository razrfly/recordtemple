class Price < ActiveRecord::Base
  has_many :records#, :dependent => :destroy
  belongs_to :record_format
  belongs_to :artist
  belongs_to :label
  belongs_to :user
  # has_one :record ????

  delegate :name, to: :artist, prefix: true, allow_nil: true
  delegate :name, to: :label, prefix: true, allow_nil: true
  delegate :name, to: :record_format, prefix: true, allow_nil: true

  validates_presence_of :artist_id, :label_id, :record_format_id
end
