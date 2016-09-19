class Label < ActiveRecord::Base
  extend FriendlyId

  has_many :records
  has_many :prices
  has_many :artists, -> { uniq }, :through => :records
  has_many :genres, -> { uniq }, :through => :records

  friendly_id :name, :use => [:slugged, :finders]

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
