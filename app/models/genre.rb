class Genre < ActiveRecord::Base
  extend FriendlyId

  has_many :records
  has_many :artists, -> { uniq }, :through => :records
  has_many :labels, -> { uniq }, :through => :records

  scope :not_empty, -> { all.map{|rf| rf if rf.records.size>0 }.compact }

  friendly_id :name, :use => [:slugged, :finders]

  validates_presence_of :name

  def name_with_count
    "#{name} (#{records.size.to_s})"
  end
end
