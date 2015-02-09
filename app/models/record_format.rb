class RecordFormat < ActiveRecord::Base
  has_many :prices
  has_many :records
  belongs_to :record_type

  # deprecated in favour of :with_records
  scope :not_empty, -> { all.map{|rf| rf if rf.records.size>0 }.compact }

  scope :with_records, -> do
    joins('LEFT OUTER JOIN records ON record_formats.id = records.record_format_id').group('record_formats.id')
      .having('count(records.id) > 0')
  end

  scope :without_records, -> do
    joins('LEFT OUTER JOIN records ON record_formats.id = records.record_format_id').group('record_formats.id')
      .having('count(records.id) = 0')
  end

  def name_with_count
    "#{name} (#{records.size.to_s})"
  end
end
