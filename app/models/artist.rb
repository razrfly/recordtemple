class Artist < ActiveRecord::Base
  extend FriendlyId

  has_many :records
  has_many :prices
  has_many :labels, :through => :records, :uniq => true
  has_many :genres, :through => :records, :uniq => true
  has_many :songs, :through => :records
  
  friendly_id :name, :use => [:slugged, :finders]

  # def name_unless_bad
  #   reserved_words = [ "index", "show", "edit", "autocomplete", "create", "destroy", "delete", "new", "update", "records", "record", "search", "searches", "stats", "statistics", "genre", "genres", "artist", "artists", "login", "logins", "home", "song", "songs", "price", "prices", "put", "puts", "post", "posts", "photo", "photos", "format", "formats", "recommendation", "recommendations" ]
  #   unless reserved_words.include?(name.downcase)
  #     name
  #   else
  #     "#{name}-the-artist"
  #   end
  # end
  
  #index do
  #  name
  #end
  
  # after_update :update_cache_children
  
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
  
  private
  
  # def update_cache_children
  #   if self.name_changed?
  #     self.records.each do |r|
  #       r.update_attribute :cached_artist, self.name
  #     end
  #   end
  # end
  
end
