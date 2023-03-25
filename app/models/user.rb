# == Schema Information
#
# Table name: users
#
#  id         :integer          not null, primary key
#  email      :string(255)      default(""), not null
#  username   :string(255)
#  created_at :datetime
#  updated_at :datetime
#
# Indexes
#
#  index_users_on_email  (email) UNIQUE
#
class User < ApplicationRecord

  validates :email,
            presence: true,
            uniqueness: { case_sensitive: false },
            format: { with: URI::MailTo::EMAIL_REGEXP }

  passwordless_with :email

  def admin?
    true
  end
end
