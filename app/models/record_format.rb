class RecordFormat < ActiveRecord::Base
  has_many :prices
  has_many :records, :through => :prices
end
