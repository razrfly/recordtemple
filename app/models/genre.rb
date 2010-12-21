class Genre < ActiveRecord::Base
  has_many :records
end
