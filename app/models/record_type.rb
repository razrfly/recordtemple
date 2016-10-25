class RecordType < ActiveRecord::Base
  has_many :record_formats
  has_many :records, -> { uniq }, :through => :record_formats

  scope :with_counted_records, -> {
    joins(:records).
    select('record_types.name, COUNT(record_format_id) as count_records').
    group('record_types.name')
  }
end