class Record < ActiveRecord::Base
  enum condition: { mint: 1, near_mint: 2, very_good_plusplus: 3,
    very_good_plus: 4, very_good: 5, good: 6, poor: 7 }

  belongs_to :price
  belongs_to :user
  belongs_to :genre
  belongs_to :label
  belongs_to :record_format
  belongs_to :artist

  attr_accessor :freebase_id

  validates_presence_of :genre, :condition, :value, :user

  has_many :photos, -> { order(:position)}, :dependent => :destroy
  has_many :songs, :dependent => :destroy

  #maybes
  #delegate :freebase_id, :to => :price

  #acts_as_tree :foreign_key => "price_id"

  delegate :name, to: :artist, prefix: true, allow_nil: true
  delegate :name, to: :genre, prefix: true, allow_nil: true
  delegate :name, to: :label, prefix: true, allow_nil: true
  delegate :name, to: :record_format, prefix: true, allow_nil: true
  delegate :detail, to: :price, prefix: true, allow_nil: true

  def self.condition_collection
    Hash[Record.conditions.map{ |k, v| [Record.transform_condition(k), k]}]
  end

  def self.transform_condition condition
    condition.gsub('_', ' ').gsub('plus', '+')
  end

  def self.pricing
    {'mint' => 1, 'near mint' => 1, 'very good ++' => 0.9, 'very good +' => 0.5, 'very good' => 0.25, 'good' => 0.2, 'poor' => 0.15}
  end

  def notes
    notes = price.detail
    price.footnote ? "#{notes} #{price.footnote}" : notes
  end

  def self.to_csv
    attributes = %w[artist_name price_detail comment label_name genre_name record_format_name get_condition]
    CSV.generate(headers: true) do |csv|
      csv << attributes

      all.each do |record|
        csv << attributes.map { |attr| record.send(attr) }
      end
    end
  end

  #acts_as_tree :foreign_key => "price_id"

  [:photos, :songs].each do |association|
    accepts_nested_attributes_for association, allow_destroy: true,
      reject_if: Proc.new { |attributes|
        attributes.except(:_destroy).reject { |_, value|
          value == "{}"
        }.empty?
      }
  end

  # after_save :add_freebase_to_parent

  scope :with_music, -> { joins(:songs) }
  scope :with_photo, -> { joins(:photos) }

  def cyberguide
    price.price_high * Record.pricing[Record.transform_condition condition] if price and condition
  end

  def cover_photo
    Refile.attachment_url(photos.first, :image, :fill, 60, 60) unless photos.blank?
  end

  def desc
    price.nil? ? comment : "#{price.detail} #{comment} #{price.footnote}"
  end

  def get_condition
    Record.transform_condition condition
  end

  def add_freebase_to_parent
    unless freebase_id.blank?
      #self.price.freebase_id = self.freebase_id
      self.price.update_attribute(:freebase_id, self.freebase_id)
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
