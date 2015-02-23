class Genre < ActiveRecord::Base
  extend FriendlyId

  has_many :records
  has_many :artists, -> { uniq }, :through => :records
  has_many :labels, -> { uniq }, :through => :records

  friendly_id :name, :use => [:slugged, :finders]
  validates_presence_of :name

  scope :with_records, lambda { |user=nil|
    if user.nil?
      joins('INNER JOIN records ON genres.id = records.genre_id')
        .group('genres.id')
        .having('count(records.id) > 0')
    else
      joins('INNER JOIN records ON genres.id = records.genre_id')
        .where('records.user_id = ?', user.id)
        .group('genres.id')
        .having('count(records.id) > 0')
    end
  }

  scope :without_records, lambda { |user=nil|
    if user.nil?
      joins('LEFT OUTER JOIN records ON genres.id = records.genre_id')
        .group('genres.id')
        .having('count(records.id) = 0')
    else
      joins('LEFT OUTER JOIN records ON genres.id = records.genre_id')
        .where('records.user_id = ?', user.id)
        .group('genres.id')
        .having('count(records.id) = 0')
    end
  }

  def name_with_records_count user=nil
    "#{name} (#{(user.nil? ? records : user.records.where(genre: self)).size})"
  end
end
