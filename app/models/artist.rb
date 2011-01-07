class Artist < ActiveRecord::Base
  has_many :records
  has_many :prices
  has_many :labels, :through => :records, :uniq => true
  has_many :songs, :through => :records
  
  has_friendly_id :name, :use_slug => true,
      # remove accents and other diacritics from Latin characters
      :approximate_ascii => true,
      # don't use slugs larger than 50 bytes
      :max_length => 50
  
  index do
    name
  end
  
  validates_presence_of :name
  
  def description
      Freebase.find(freebase_id).description unless freebase_id.blank?
  end
  
  def thumbnail
      Freebase.find(freebase_id).thumbnail unless freebase_id.blank?
  end
  
  def self.find_freebase(artist)
    search = Ken.session.mqlread([{
      :type => "/music/artist",
      :id => nil,
      :limit => 1,
      :name => artist
    }])
  end
  
end
