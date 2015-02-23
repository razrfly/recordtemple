class RecordFormat < ActiveRecord::Base
  has_many :prices
  has_many :records
  belongs_to :record_type

  scope :with_records, lambda { |user=nil|
    if user.nil?
      joins('INNER JOIN records ON record_formats.id = records.record_format_id')
        .group('record_formats.id')
        .having('count(records.id) > 0')
    else
      joins('INNER JOIN records ON record_formats.id = records.record_format_id')
        .where('records.user_id = ?', user.id)
        .group('record_formats.id')
        .having('count(records.id) > 0')
    end
  }

  scope :without_records, lambda { |user=nil|
    if user.nil?
      joins('LEFT OUTER JOIN records ON record_formats.id = records.record_format_id')
        .group('record_formats.id')
        .having('count(records.id) = 0')
    else
      joins('LEFT OUTER JOIN records ON record_formats.id = records.record_format_id')
        .where('records.user_id = ?', user.id)
        .group('record_formats.id')
        .having('count(records.id) = 0')
    end
  }

  scope :with_prices, lambda {
      joins('INNER JOIN prices ON record_formats.id = prices.record_format_id')
        .group('record_formats.id')
  }

  def name_with_records_count user=nil
    "#{name} (#{(user.nil? ? records : user.records.where(record_format: self)).size.to_s })"
  end

  def name_with_prices_count
    "#{name} (#{prices.size.to_s})"
  end
end
