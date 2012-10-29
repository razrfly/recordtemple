#class Search < ActiveRecord::Base
#  
#  #normalize_attribute :term, :with => :plain_string
#    
#  # We want to reference various models
#  belongs_to :searchable, :polymorphic => true
#  # Eliminate n + 1 query problems
#  default_scope :include => :searchable
#  
#  # Add all fields we want indexed
#  index do
#    term
#  end
#    
#  # Search.new('query') to search for 'query'
#  # across searchable models
#  #def self.new(query)
#  #  query = query.to_s
#  #  return [] if query.empty?
#  #  self.search(query)#.map!(&:searchable)
#  #end
#    
#  # Search records are never modified
#  def readonly?; true; end
#  
#  
#  #def records(page)
#  #  @records ||= find_records(page)
#  #end
#  #
#  #private
#  #
#  #def find_records(page)
#  #  scope = Record.scoped({})
#  #  #artist
#  #  scope = scope.scoped :joins => "left outer join prices on prices.id = records.price_id",
#  #                       :conditions => ["LOWER(artist) LIKE ?", "%#{artist.downcase}%"] unless artist.blank?
#  #  #label
#  #  scope = scope.scoped :joins => "left outer join prices on prices.id = records.price_id",
#  #                       :conditions => ["LOWER(label) LIKE ?", "%#{label.downcase}%"] unless label.blank?
#  #  #format
#  #  scope = scope.scoped :joins => "left outer join prices on prices.id = records.price_id",
#  #                       :conditions => ["LOWER(format) LIKE ?", "%#{format.downcase}%"] unless format.blank?  
#  #  #price (between $ .. $)
#  #  scope = scope.scoped :joins => "left outer join prices on prices.id = records.price_id",
#  #                       :conditions => ["pricelow >= ?", minimum_value] unless minimum_value.blank?
#  #  scope = scope.scoped :joins => "left outer join prices on prices.id = records.price_id",
#  #                       :conditions => ["pricehigh <= ?", maximum_value] unless maximum_value.blank?
#  #  #genre
#  #  scope = scope.scoped :conditions => ["genre = ?", genre] unless genre.blank?
#  #  #title (like)
#  #  scope = scope.scoped :joins => "left outer join prices on prices.id = records.price_id",
#  #                       :conditions => ["detail LIKE ? or footnote LIKE ?", "%#{title}%", "%#{title}%"] unless title.blank?
#  #  
#  #  #condition
#  #  scope = scope.scoped :conditions => ["'condition' <= ?", condition] unless condition.blank?
#  #  scope.paginate :per_page => 25, :page => page
#  #end
#end
#