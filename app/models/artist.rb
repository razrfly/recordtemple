class Artist < ActiveRecord::Base
  has_many :records
  has_many :prices
  
  validates_presence_of :name
  
  def self.find_freebase(artist)
    
    search = Ken.session.mqlread([{
      :type => "/music/artist",
      :id => nil,
      :limit => 1,
      :name => artist
    }])
    
  end
end
