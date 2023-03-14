# == Schema Information
#
# Table name: genres
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  slug       :string(255)
#  created_at :datetime
#  updated_at :datetime
#
# Indexes
#
#  index_genres_on_slug  (slug) UNIQUE
#
require "test_helper"

class GenreTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
