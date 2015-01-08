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
    [bubbles.last.low, bubbles.last.high].join('-')
    #[pricelow, pricehigh].join('-')
  end

  def top_price
    bubbles.last.high unless bubbles.last.blank?
  end

  def date_range
    if yearbegin == yearend
      yearbegin
    else
      [yearbegin, yearend].join('-')
    end
  end

  def get_format
    #Price.find(:all, :group => :format, :order => 'format', :limit => 20)
    Price.find(:all, :select => 'DISTINCT(format), COUNT(format)', :group => :format, :order => 'COUNT(format) DESC', :limit => 8)
    #["Singles","LPs","EPs","Picture Sleeves"]
  end

end
