class RecordFormat < ActiveRecord::Base
  has_many :prices
  has_many :records
  belongs_to :record_type

  def name_with_count
    "#{name} (#{records.size.to_s})"
  end
end
