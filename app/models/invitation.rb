class Invitation
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :email

  validates :email, presence: true, format: Devise::email_regexp

end
