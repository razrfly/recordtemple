class RecordFormat < ActiveRecord::Base
  has_many :prices
  has_many :records
  belongs_to :record_type

  scope :not_empty, -> { all.map{|rf| rf if rf.records.size>0 }.compact }

  def name_with_count
    "#{name} (#{records.size.to_s})"
  end
end
