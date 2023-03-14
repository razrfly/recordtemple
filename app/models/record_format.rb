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
class RecordFormat < ApplicationRecord
  belongs_to :record_type
end
