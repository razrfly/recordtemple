class Record < ActiveRecord::Base
  belongs_to :price
  belongs_to :user
  belongs_to :genre
  #belonds_to :label
  has_one :photo
  belongs_to :record_format
  belongs_to :artist
  
  attr_accessor :freebase_id
  
 #scope :genres, Genre.where('id IN ?', map(&:genre_id).uniq!)
  #scope :artists, Artist.where('name IN (?)', @search.result.map(&:cached_artist).uniq!).limit(10)
  
  validates_presence_of :price, :genre, :condition, :value, :user#, :artist, :label

  has_many :photos, :order => :position, :dependent => :destroy
  has_many :songs, :dependent => :destroy

  #has_many :genres do
  #  def narrow_genres
  #    #return map(&:turnaround).inject(:+) / count
  #    return map(&:genre_id)
  #    #return Genre.where('id IN ?', map(&:genre_id).uniq!)
  #  end    
  #end
  
  delegate :detail, :to => :price
  #maybes
  delegate :label, :to => :price
  #delegate :freebase_id, :to => :price
  
  def notes
    notes = price.detail
    price.footnote ? notes += ' '+ price.footnote : notes
  end
  
  #acts_as_tree :foreign_key => "price_id"
  accepts_nested_attributes_for :photos, :songs
  
  before_save :cache_columns
  after_save :add_freebase_to_parent
  
  scope :with_music, joins(:songs)
  scope :with_photo, joins(:photos)
  
  def cyberguide
    if condition <= 2
      price.bubbles.last.high
    elsif condition == 3
      price.bubbles.last.high * 0.9
    elsif condition == 4
      price.bubbles.last.high * 0.5
    elsif condition == 5
      price.bubbles.last.high * 0.25
    elsif condition == 6
      price.bubbles.last.high * 0.2
    else
      price.bubbles.last.high * 0.15
    end
  end
  
  def cover_photo
    unless photos.blank?
      photos.first.data(:thumb)
    else
      " "
    end
  end
  
  #def prices
  #  price.bubbles
  #end
  
  def cache_columns
    self.cached_artist = price.artist.name
    self.cached_label = price.label.name
  end
  
  def desc
    "#{price.detail} #{comment} #{price.footnote}"
  end
  
  def the_condition
    conditions[condition-1]
  end
  
  def get_condition
    [["Mint", 1], ["Near Mint", 2], ["Very Good ++", 3], ["Very Good +", 4], ["Very Good", 5], ["Good", 6], ["Poor", 7]]
  end
  
  def conditions
    ["Mint", "Near Mint", "Very Good ++", "Very Good +", "Very Good", "Good", "Poor"]
  end
  
  CONDITIONS = ["Mint", "Near Mint", "Very Good ++", "Very Good +", "Very Good", "Good", "Poor"]
  #FORMAT = ["Mint", "Near Mint", "Very Good ++", "Very Good +", "Very Good", "Good", "Poor"]
  
  def add_freebase_to_parent
    unless freebase_id.blank?
      #self.price.freebase_id = self.freebase_id
      self.price.update_attribute(:freebase_id, self.freebase_id)
    end
  end
    
end
