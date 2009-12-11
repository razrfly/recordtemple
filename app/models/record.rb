class Record < ActiveRecord::Base
  belongs_to :price
  validates_presence_of :price_id, :genre, :condition, :user 
  has_many :mugshots, :dependent => :destroy
  has_many :photos
  
  def self.search(search, page, user)
    paginate :per_page => 20, :page => page,
                                :joins => "left outer join prices on prices.id = records.price_id",
                                :conditions => ['artist like ? and user = ?', "%#{search}%", user],
                                :order => 'updated_at DESC'
  end
  
  def self.values(search, user)
    Record.sum(:value, :joins => "left outer join prices on prices.id = records.price_id",
                            :conditions => ['artist like ? and user = ?', "%#{search}%", user])
  end
  
  def self.osbourne(search, user)
    Record.sum(:pricehigh, :joins => "left outer join prices on prices.id = records.price_id",
               :conditions => ['artist like ? and user = ?', "%#{search}%", user])
  end
  
  def cyberguide
    if condition <= 2
      [price.bubbles.last.high]
    elsif condition == 3
      [price.bubbles.last.high * 0.9]
    elsif condition == 4
      [price.bubbles.last.high * 0.5]
    elsif condition == 5
      [price.bubbles.last.high * 0.25]
    elsif condition == 6
      [price.bubbles.last.high * 0.2]
    else
      [price.bubbles.last.high * 0.15]
    end
  end
  
  def cando
    5
  end

  
  def get_genre
    [["Rock 'n' Roll", 1], ["Surf", 2], ["Rockabilly", 3], ["Doo Wop", 4], ["Instrumental", 5], ["R&B", 6], ["Rock", 7], ["Country", 8], ["Easy Listening", 9], ["Jazz", 10], ["Northern Soul", 11], ["Pop", 12], ["Psychedelic/Garage", 13], ["Soul", 14], ["Soundtrack", 15], ["X-mas", 16]]
  end
  
  def get_condition
    [["Mint", 1], ["Near Mint", 2], ["Very Good ++", 3], ["Very Good +", 4], ["Very Good", 5], ["Good", 6], ["Poor", 7]]
  end
  
  def mugshot_attributes=(mugshot_attributes)
    mugshot_attributes.each do |attributes|
      mugshots.build(attributes)
    end
  end
  
  def self.chart_raw
    Record.find_by_sql("SELECT Year(created_at) as year, DATE_FORMAT(created_at, '%M') as month, COUNT(id) as num 
                        FROM `records` WHERE created_at BETWEEN DATE_ADD(CURDATE(), INTERVAL -6 MONTH) AND CURDATE()
                        GROUP BY year, month")
  end
  
  def self.chart_months
    chart = Record.chart_raw
    months = ""
    
    chart.each do |item|
      months += "#{item.month}|"
    end
    
    return months.chop
    
  end
  
  def self.chart_months_data
    chart = Record.chart_raw
    data = ""
    total = 0
    
    chart.each do |item|
      total += item.num.to_i
    end    
    
    chart.each do |item|
      data += "#{((item.num.to_f/total)*100).to_s},"
    end
    
    return data.chop
    #return total
    
  end
    
end
