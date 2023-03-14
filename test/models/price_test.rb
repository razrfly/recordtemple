# == Schema Information
#
# Table name: prices
#
#  id               :integer          not null, primary key
#  cached_artist    :string(255)
#  cached_label     :string(255)
#  detail           :string(255)
#  footnote         :text
#  media_type       :string(255)
#  price_high       :integer
#  price_low        :integer
#  yearbegin        :integer
#  yearend          :integer
#  created_at       :datetime
#  updated_at       :datetime
#  artist_id        :integer
#  freebase_id      :string(255)
#  label_id         :integer
#  record_format_id :integer
#  user_id          :integer
#
# Indexes
#
#  index_prices_on_cached_artist_trigram  (cached_artist) USING gin
#  index_prices_on_cached_label_trigram   (cached_label) USING gin
#  index_prices_on_detail_trigram         (detail) USING gin
#  index_prices_on_media_type_trigram     (media_type) USING gin
#
require "test_helper"

class PriceTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
