class Record < ActiveRecord::Base
  enum condition: { mint: 1, near_mint: 2, very_good_plusplus: 3, very_good_plus: 4, very_good: 5, good: 6, poor: 7 }

  belongs_to :price
  belongs_to :user
  belongs_to :genre
  belongs_to :label
  has_one :photo
  belongs_to :record_format
  belongs_to :artist

  attr_accessor :freebase_id

  validates_presence_of :price, :genre, :condition, :value, :user#, :artist, :label

  has_many :photos, -> { order(:position)}, :dependent => :destroy
  has_many :songs, :dependent => :destroy
  #has_many :genres do
  #  def narrow_genres
  #    #return map(&:turnaround).inject(:+) / count
  #    return map(&:genre_id)
  #    #return Genre.where('id IN ?', map(&:genre_id).uniq!)
  #  end
  #end

  #scope :genres, Genre.where('id IN ?', map(&:genre_id).uniq!)
  #scope :artists, Artist.where('name IN (?)', @search.result.map(&:cached_artist).uniq!).limit(10)

  #maybes
  #delegate :freebase_id, :to => :price

  #acts_as_tree :foreign_key => "price_id"

  delegate :detail, :to => :price

  def notes
    notes = price.detail
    price.footnote ? "#{notes} #{price.footnote}" : notes
  end

  #acts_as_tree :foreign_key => "price_id"
  accepts_nested_attributes_for :photos, :songs

  before_save :cache_columns
  after_save :add_freebase_to_parent

  scope :with_music, -> { joins(:songs) }
  scope :with_photo, -> { joins(:photos) }

  ## FIX ME, I'M UGLY
  def cyberguide
    if get_condition == 'mint' or get_condition == 'near mint'
      price.price_high
    elsif get_condition == 'very good ++'
      price.price_high * 0.9
    elsif get_condition == 'very good +'
      price.price_high * 0.5
    elsif get_condition == 'very good'
      price.price_high * 0.25
    elsif get_condition == 'good'
      price.price_high * 0.2
    else
      price.price_high * 0.15
    end
  end

  def cover_photo
    photos.first.data(:thumb) unless photos.blank?
  end

  def cache_columns
    self.cached_artist = price.artist.name
    self.cached_label = price.label.name
  end

  def desc
    "#{price.detail} #{comment} #{price.footnote}"
  end


  def get_condition
    Record.transform_condition condition
  end

  def self.transform_condition condition
    condition.gsub('_', ' ').gsub('plus', '+')
  end

  def add_freebase_to_parent
    unless freebase_id.blank?
      #self.price.freebase_id = self.freebase_id
      self.price.update_attribute(:freebase_id, self.freebase_id)
    end
  end

end
