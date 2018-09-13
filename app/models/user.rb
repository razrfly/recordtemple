class User < ActiveRecord::Base
  extend FriendlyId

  devise :database_authenticatable, :registerable, :recoverable,
    :rememberable, :trackable, :validatable

  has_many :records
  has_many :prices
  has_many :photos, through: :records
  has_many :songs, through: :records
  has_many :pages

  validates :username, presence: true, uniqueness: true

  friendly_id :username, use: [:slugged, :finders]

  attachment :avatar

  # def active?
  #   invitation_accepted_at.present? | (invitation_accepted_at.nil? & invitation_sent_at.nil?)
  # end

  # def name
  #   "#{fname} #{lname}" if fname.present? or lname.present?
  # end

  def admin?
    true
  end

  def should_generate_new_friendly_id?
    username_changed?
  end

  def owner?(entity = nil)
    !!(entity) && entity.respond_to?(:user) ? entity.user == self : false
  end
end
