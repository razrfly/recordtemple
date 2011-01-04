class Label < ActiveRecord::Base
  has_many :records
  has_many :prices
  
  validates_presence_of :name
  
end
