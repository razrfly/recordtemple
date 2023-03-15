# == Schema Information
#
# Table name: labels
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  slug       :string(255)
#  created_at :datetime
#  updated_at :datetime
#
# Indexes
#
#  index_labels_on_name  (name) UNIQUE
#  index_labels_on_slug  (slug) UNIQUE
#  labels_fts_idx        (to_tsvector('english'::regconfig, (COALESCE(name, ''::character varying))::text)) USING gin
#
require "test_helper"

class LabelTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
