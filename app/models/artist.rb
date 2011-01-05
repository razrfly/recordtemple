class Artist < ActiveRecord::Base
  has_many :records
  has_many :prices
  
  index do
    name
  end
  
  validates_presence_of :name
  
  def self.find_freebase(artist)
    
    search = Ken.session.mqlread([{
      :type => "/music/artist",
      :id => nil,
      :limit => 1,
      :name => artist
    }])
    
  end
  
  def uncomma
    if name.match(',')
      new_name = name.split(',')
      "#{new_name.last.lstrip} #{new_name.first}" 
    else
      name
    end
  end
end
