class User < ActiveRecord::Base
  has_many :records
  has_many :prices
  has_many :photos, through: :records
  has_many :songs, through: :records
  has_many :pages

  extend FriendlyId
  friendly_id :username, use: [:slugged, :finders]

  devise :database_authenticatable, :registerable, :recoverable,
    :rememberable, :trackable, :validatable

  attachment :avatar

  # def active?
  #   invitation_accepted_at.present? | (invitation_accepted_at.nil? & invitation_sent_at.nil?)
  # end

  # def name
  #   "#{fname} #{lname}" if fname.present? or lname.present?
  # end
end
