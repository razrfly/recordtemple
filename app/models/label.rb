class Label < ActiveRecord::Base
  has_many :records
  has_many :prices
  has_many :artists, :through => :records, :uniq => true
  
  index do
    name
  end
  
  validates_presence_of :name
  
  
  def self.find_freebase(label)
    
    search = Ken.session.mqlread([{
      :type => "/music/record_label",
      :id => nil,
      :limit => 1,
      :"name~=" => label
    }])
    
  end
  
  #def self.freebase(id)
  #  
  #  search = Ken.session.mqlread([{
  #    :id => id,
  #    :name => nil,
  #    :"/common/topic/image" : [{ "id" : null, "optional" : true, "limit" : 3 }]
  #  }])
  #  
  #end
end
