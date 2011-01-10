class RecordListing < ActiveRecord::Base
  belongs_to :record
  attr_accessible :record_id, :external_id, :listing_type
  
  validates_presence_of :record_id, :external_id, :listing_type
  
  def listing_type
    ["Ebay (sandbox)", "Tumblr"]
  end
  
  TYPES = ["Ebay (sandbox)", "Tumblr"]
end
