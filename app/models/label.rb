class Label < ActiveRecord::Base
  extend FriendlyId

  has_many :records
  has_many :prices
  has_many :artists, :through => :records, :uniq => true
  has_many :genres, :through => :records, :uniq => true
  
  friendly_id :name, :use => [:slugged, :finders]
      
  # def name_unless_bad
  #   reserved_words = [ "index", "show", "create", "destroy", "delete", "new", "update" ]
  #   unless reserved_words.include?(name.downcase)
  #     name
  #   else
  #     "#{name}-the-artist"
  #   end
  # end
  
  #index do
  #  name
  #end
  
  validates_presence_of :name
  
  def description
      Freebase.find(freebase_id).description unless freebase_id.blank?
  end
  
  def thumbnail
      Freebase.find(freebase_id).thumbnail unless freebase_id.blank?
  end
  
  def self.find_freebase(label)  
    search = Ken.session.mqlread([{
      :type => "/music/record_label",
      :id => nil,
      :limit => 1,
      :"name~=" => label
    }])
  end
  
end
