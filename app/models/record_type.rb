class RecordType < ActiveRecord::Base
  has_many :record_formats
  has_many :records, -> { uniq }, :through => :record_formats
end