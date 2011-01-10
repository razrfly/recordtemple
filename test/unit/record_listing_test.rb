require 'test_helper'

class RecordListingTest < ActiveSupport::TestCase
  def test_should_be_valid
    assert RecordListing.new.valid?
  end
end
