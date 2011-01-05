class Label < ActiveRecord::Base
  has_many :records
  has_many :prices
  
  validates_presence_of :name
  
  
  def self.find_freebase(label)
    
    search = Ken.session.mqlread([{
      :type => "/music/record_label",
      :id => nil,
      :limit => 1,
      :"name~=" => label
    }])
    
  end
end
