# == Schema Information
#
# Table name: prices
#
#  id               :integer          not null, primary key
#  cached_artist    :string(255)
#  media_type       :string(255)
#  cached_label     :string(255)
#  detail           :string(255)
#  price_low        :integer
#  price_high       :integer
#  yearbegin        :integer
#  yearend          :integer
#  created_at       :datetime
#  updated_at       :datetime
#  footnote         :text
#  artist_id        :integer
#  label_id         :integer
#  record_format_id :integer
#  user_id          :integer
#
# Indexes
#
#  index_prices_on_cached_artist_trigram  (cached_artist)
#  index_prices_on_cached_label_trigram   (cached_label)
#  index_prices_on_detail_trigram         (detail)
#  index_prices_on_media_type_trigram     (media_type)
#

require "test_helper"

class PriceTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
