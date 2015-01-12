class Price < ActiveRecord::Base
  has_many :records#, :dependent => :destroy
  belongs_to :record_format
  belongs_to :artist
  belongs_to :label
  belongs_to :user
  has_one :record

  #accepts_nested_attributes_for :records

  attr_accessor :artist_name
  attr_accessor :label_name

  validates_presence_of :artist_id, :label_id, :record_format_id
  before_save :cache_columns

  def cache_columns
    self.media_type = record_format.name
    self.cached_artist = artist.name
    self.cached_label = label.name
  end

  def price_range
    [price_low, price_high].join('-')
  end

  def date_range
    if yearbegin == yearend
      yearbegin
    else
      [yearbegin, yearend].join('-')
    end
  end

end
