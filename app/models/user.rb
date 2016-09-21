class User < ActiveRecord::Base
  extend FriendlyId
  friendly_id :username, use: [:slugged, :finders]

  devise :database_authenticatable, :registerable, :recoverable,
    :rememberable, :trackable, :validatable

  has_many :records
  has_many :prices
  has_many :photos, through: :records
  has_many :songs, through: :records
  has_many :pages

  attachment :avatar
end
