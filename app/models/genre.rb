class Genre < ActiveRecord::Base
  extend FriendlyId

  has_many :records
  has_many :artists, -> { uniq }, :through => :records
  has_many :labels, -> { uniq }, :through => :records

  friendly_id :name, :use => [:slugged, :finders]

  def name_with_count
    "#{name} (#{records.size.to_s})"
  end
end
