class Genre < ActiveRecord::Base
  extend FriendlyId

  has_many :records
  has_many :artists, :through => :records, :uniq => true
  has_many :labels, :through => :records, :uniq => true
  
  friendly_id :name, :use => [:slugged, :finders]
  
  def name_with_count
    "#{name} (#{records.size.to_s})"
  end
end
