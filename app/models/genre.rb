class Genre < ActiveRecord::Base
  has_many :records
  has_many :artists, :through => :records, :uniq => true
  has_many :labels, :through => :records, :uniq => true
  
  has_friendly_id :name, :use_slug => true,
      # remove accents and other diacritics from Latin characters
      :approximate_ascii => true,
      # don't use slugs larger than 50 bytes
      :max_length => 50
  
  def name_with_count
    "#{name} (#{records.size.to_s})"
  end
end
