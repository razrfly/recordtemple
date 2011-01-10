class UserAccount < ActiveRecord::Base
  belongs_to :user
  attr_accessible :provider, :auth_type, :key, :secret, :user_id
end
