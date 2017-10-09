class Record < ActiveRecord::Base
  attr_accessor :freebase_id

  enum condition: { mint: 1, near_mint: 2, very_good_plusplus: 3,
    very_good_plus: 4, very_good: 5, good: 6, poor: 7 }

  belongs_to :price
  belongs_to :user
  belongs_to :genre
  belongs_to :label
  belongs_to :record_format
  has_one :record_type, through: :record_format
  belongs_to :artist

  has_many :photos, -> { order(:position)}, :dependent => :destroy
  has_many :songs, :dependent => :destroy

  validates_presence_of :genre, :condition, :value, :user

  [:photos, :songs].each do |association|
    accepts_nested_attributes_for association, allow_destroy: true,
      reject_if: Proc.new { |attributes|
        attributes.except(:_destroy).reject { |_, value|
          value == "{}"
        }.empty?
      }
  end

  delegate :name, to: :artist, prefix: true, allow_nil: true
  delegate :name, to: :genre, prefix: true, allow_nil: true
  delegate :name, to: :label, prefix: true, allow_nil: true
  delegate :name, to: :record_format, prefix: true, allow_nil: true
  delegate :name, to: :record_type, prefix: true, allow_nil: true
  delegate :detail, to: :price, prefix: true, allow_nil: true

  scope :with_music, -> { joins(:songs) }
  scope :with_photo, -> { joins(:photos) }

  def self.to_csv
    attributes = %w[artist_name price_detail comment label_name
      genre_name record_format_name condition]

    CSV.generate(headers: true) do |csv|
      csv << attributes

      all.each do |record|
        csv << attributes.map { |attr| record.send(attr) }
      end
    end
  end

  def to_param
    elements = ['artist', 'label'].each_with_object([]) do |element, result|
      self.send(element) && (result << self.send("#{element}_name").parameterize)
    end

    elements.prepend(id).join('-')
  end
end
