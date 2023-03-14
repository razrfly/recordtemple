# == Schema Information
#
# Table name: artists
#
#  id          :integer          not null, primary key
#  name        :string(255)
#  slug        :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#  freebase_id :string(255)
#
# Indexes
#
#  artists_fts_idx        (to_tsvector('english'::regconfig, (COALESCE(name, ''::character varying))::text)) USING gin
#  index_artists_on_name  (name) UNIQUE
#  index_artists_on_slug  (slug) UNIQUE
#
require "test_helper"

class ArtistTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
