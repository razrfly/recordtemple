class Record < ActiveRecord::Base
  belongs_to :price
  belongs_to :user
  belongs_to :artist
  belongs_to :label
  belongs_to :genre
  
  index do
    comment
  end
  
  validates_presence_of :price_id, :genre, :condition, :user, :artist, :label

  has_many :photos, :dependent => :destroy
  has_many :songs, :dependent => :destroy
  has_many :recommendations
  
  acts_as_tree :foreign_key => "price_id"
  accepts_nested_attributes_for :photos, :songs
  
  before_save :cache_columns
  
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
  
  def cache_columns
    self.cached_artist = artist.name
    self.cached_label = label.name
  end
  
  def desc
    "#{price.detail} #{comment}"
  end
  
  #def cando
  #  5
  #end

  #def get_genre
  #  [["Rock 'n' Roll", 1], ["Surf", 2], ["Rockabilly", 3], ["Doo Wop", 4], ["Instrumental", 5], ["R&B", 6], ["Rock", 7], ["Country", 8], ["Easy Listening", 9], ["Jazz", 10], ["Northern Soul", 11], ["Pop", 12], ["Psychedelic/Garage", 13], ["Soul", 14], ["Soundtrack", 15], ["X-mas", 16]]
  #end
  
  def get_condition
    [["Mint", 1], ["Near Mint", 2], ["Very Good ++", 3], ["Very Good +", 4], ["Very Good", 5], ["Good", 6], ["Poor", 7]]
  end
    
end
