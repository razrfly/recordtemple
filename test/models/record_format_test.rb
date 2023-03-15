# == Schema Information
#
# Table name: record_formats
#
#  id             :integer          not null, primary key
#  name           :string(255)
#  created_at     :datetime
#  updated_at     :datetime
#  record_type_id :integer
#
# Foreign Keys
#
#  fk_rails_...  (record_type_id => record_types.id)
#
require "test_helper"

class RecordFormatTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
