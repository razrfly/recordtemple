class User < ActiveRecord::Base
  has_many :records
  has_many :prices

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable

  def active?
    invitation_accepted_at.present? | (invitation_accepted_at.nil? & invitation_sent_at.nil?)
  end

end
