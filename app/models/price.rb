class Price < ActiveRecord::Base
  has_many :records#, :dependent => :destroy
  has_many :bubbles, :dependent => :destroy
  belongs_to :record_format
  belongs_to :artist
  belongs_to :label
  belongs_to :user
  
  #accepts_nested_attributes_for :records

  #index do
  #  detail
  #  footnote
  #end

  validates_presence_of :artist, :label, :record_format, :label_id
  before_save :cache_columns
  
  def cache_columns
    self.media_type = record_format.name
    self.cached_artist = artist.name
    self.cached_label = label.name
  end

  cattr_reader :per_page
  @@per_page = 50

  def price_range
    [bubbles.last.low, bubbles.last.high].join('-')
    #[pricelow, pricehigh].join('-')
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
