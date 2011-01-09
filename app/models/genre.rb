class Genre < ActiveRecord::Base
  has_many :records
  
  index do
    name
  end
end
