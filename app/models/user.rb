class User < ActiveRecord::Base
  has_many :records
  has_many :prices
  has_many :photos, through: :records
  has_many :songs, through: :records

  extend FriendlyId
  friendly_id :username, use: [:slugged, :finders]

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable

  def active?
    invitation_accepted_at.present? | (invitation_accepted_at.nil? & invitation_sent_at.nil?)
  end

  def name
    username.present?
      username
    elsif fname.present?
      fname
    else
      email.split('@').first
    end
  end

end
