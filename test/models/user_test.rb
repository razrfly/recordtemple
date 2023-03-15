# == Schema Information
#
# Table name: users
#
#  id             :integer          not null, primary key
#  email          :string(255)      default(""), not null
#  remember_token :string(255)
#  username       :string(255)
#  created_at     :datetime
#  updated_at     :datetime
#
# Indexes
#
#  index_users_on_email  (email) UNIQUE
#
require "test_helper"

class UserTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
