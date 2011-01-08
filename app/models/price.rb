class Price < ActiveRecord::Base
  has_many :records, :dependent => :destroy
  has_many :bubbles, :dependent => :destroy
  belongs_to :record_format

  index do
    detail
    footnote
  end

  validates_presence_of :artist, :label, :format, :label_id
  #named_scope :find_artist, :conditions => ["artist like ?", "%beatles"]

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
