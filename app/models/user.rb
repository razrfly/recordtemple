class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable

  # Setup accessible (or protected) attributes for your model
  # attr_accessible :email, :password, :password_confirmation, :remember_me, :nickname, :fname, :lname
  
  has_many :records
  has_many :prices
  
  def admin?
    if email == "greg2man@gmail.com"
      true
    else
      false
    end
  end
  
  def role?(role)
    if email.blank?
      false
    else
      true
    end
  end
  
end