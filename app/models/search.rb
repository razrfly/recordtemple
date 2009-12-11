class Search < ActiveRecord::Base
  def records
    @records ||= find_records
  end
  
  private
  
  def find_records
    scope = Record.scoped({})
    #artist
    scope = scope.scoped :joins => "left outer join prices on prices.id = records.price_id",
                         :conditions => ["artist LIKE ?", "%#{artist}%"] unless artist.blank?
    #label
    scope = scope.scoped :joins => "left outer join prices on prices.id = records.price_id",
                         :conditions => ["label LIKE ?", "%#{label}%"] unless label.blank?
    #format
    scope = scope.scoped :joins => "left outer join prices on prices.id = records.price_id",
                         :conditions => ["format LIKE ?", "%#{format}%"] unless format.blank?  
    #price (between $ .. $)
    scope = scope.scoped :joins => "left outer join prices on prices.id = records.price_id",
                         :conditions => ["pricelow >= ?", minimum_value] unless minimum_value.blank?
    scope = scope.scoped :joins => "left outer join prices on prices.id = records.price_id",
                         :conditions => ["pricehigh <= ?", maximum_value] unless maximum_value.blank?
    #genre
    scope = scope.scoped :conditions => ["genre = ?", genre] unless genre.blank?
    #title (like)
    scope = scope.scoped :joins => "left outer join prices on prices.id = records.price_id",
                         :conditions => ["detail LIKE ? or footnote LIKE ?", "%#{title}%", "%#{title}%"] unless title.blank?
    
    #condition
    scope = scope.scoped :conditions => ["'condition' <= ?", condition] unless condition.blank?
    scope.paginate :per_page => 5, :page => page
  end
end
