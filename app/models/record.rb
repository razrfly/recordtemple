class Record < ActiveRecord::Base
  attr_accessor :freebase_id

  enum condition: { mint: 1, near_mint: 2, very_good_plusplus: 3,
    very_good_plus: 4, very_good: 5, good: 6, poor: 7 }

  belongs_to :price
  belongs_to :user
  belongs_to :genre
  belongs_to :label
  belongs_to :record_format
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
  delegate :detail, to: :price, prefix: true, allow_nil: true

  scope :with_music, -> { joins(:songs) }
  scope :with_photo, -> { joins(:photos) }

  #Do we need this?
  # def self.pricing
  #   {'mint' => 1, 'near mint' => 1, 'very good ++' => 0.9,
  #     'very good +' => 0.5, 'very good' => 0.25, 'good' => 0.2,
  #       'poor' => 0.15}
  # end

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
    [
      id,
      artist_name.parameterize,
      label_name.parameterize,
    ].reject(&:blank?).join("-")
  end
end
