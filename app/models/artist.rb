class Artist < ActiveRecord::Base
  extend FriendlyId

  has_many :records
  has_many :prices
  has_many :labels, -> { uniq }, :through => :records
  has_many :genres, -> { uniq }, :through => :records
  has_many :songs, :through => :records
  has_many :photos, :through => :records

  friendly_id :name, :use => [:slugged, :finders]

  validates_presence_of :name

  scope :active, -> { joins(:records).includes(:photos).uniq }

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
