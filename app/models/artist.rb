class Artist < ActiveRecord::Base
  has_many :records
  has_many :prices
end
