class Price < ActiveRecord::Base
  has_many :records, :dependent => :destroy
  has_many :bubbles, :dependent => :destroy
  validates_presence_of :artist, :label, :format
  #named_scope :find_artist, :conditions => ["artist like ?", "%beatles"]

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
    Price.find_by_sql("SELECT DISTINCT format FROM prices LIMIT 8")
    #["Singles","LPs","EPs","Picture Sleeves"]
  end
  

  
end
