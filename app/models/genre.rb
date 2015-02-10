class Genre < ActiveRecord::Base
  extend FriendlyId

  has_many :records
  has_many :artists, -> { uniq }, :through => :records
  has_many :labels, -> { uniq }, :through => :records

  # deprecated in favour of :with_records
  scope :not_empty, -> { all.map{|rf| rf if rf.records.size>0 }.compact }

  scope :with_records, -> do
    joins('LEFT OUTER JOIN records ON genres.id = records.record_format_id').group('genres.id')
      .having('count(records.id) > 0')
  end

  scope :without_records, -> do
    joins('LEFT OUTER JOIN records ON genres.id = records.record_format_id').group('genres.id')
      .having('count(records.id) = 0')
  end

  friendly_id :name, :use => [:slugged, :finders]

  validates_presence_of :name

  def name_with_count
    "#{name} (#{records.size.to_s})"
  end
end
