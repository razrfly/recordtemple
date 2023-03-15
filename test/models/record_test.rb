# == Schema Information
#
# Table name: records
#
#  id               :integer          not null, primary key
#  cached_artist    :string(255)
#  cached_label     :string(255)
#  comment          :text
#  condition        :integer
#  value            :integer
#  created_at       :datetime
#  updated_at       :datetime
#  artist_id        :integer
#  genre_id         :integer
#  identifier_id    :integer
#  label_id         :integer
#  price_id         :integer
#  record_format_id :integer
#  user_id          :integer
#
# Indexes
#
#  index_records_on_artist_id         (artist_id)
#  index_records_on_genre_id          (genre_id)
#  index_records_on_label_id          (label_id)
#  index_records_on_price_id          (price_id)
#  index_records_on_record_format_id  (record_format_id)
#  index_records_on_user_id           (user_id)
#  records_fts_idx                    (to_tsvector('english'::regconfig, COALESCE(comment, ''::text))) USING gin
#
# Foreign Keys
#
#  fk_rails_...  (artist_id => artists.id)
#  fk_rails_...  (genre_id => genres.id)
#  fk_rails_...  (label_id => labels.id)
#  fk_rails_...  (price_id => prices.id)
#  fk_rails_...  (record_format_id => record_formats.id)
#  fk_rails_...  (user_id => users.id)
#
require "test_helper"

class RecordTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
