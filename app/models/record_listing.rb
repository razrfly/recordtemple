class RecordListing < ActiveRecord::Base
  belongs_to :record
  # attr_accessible :record_id, :external_id, :listing_type
  attr_accessor :tumblr_type, :body
  
  validates_presence_of :record_id, :external_id, :listing_type
  
  TYPES = ["Ebay (sandbox)", "Tumblr"]
  TUMBLR_TYPES = %w[photo audio regular]
  
  def tumblr_types
    %w[photo audio regular]
  end
end
