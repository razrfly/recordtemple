# == Schema Information
#
# Table name: record_types
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#
class RecordType < ApplicationRecord
end
