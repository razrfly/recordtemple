class Recommendation < ActiveRecord::Base
  attr_accessible :email, :message, :token, :expiration, :record_id
  belongs_to :record
  
  before_create :generate_token, :set_expiration
  
  private
  
  def generate_token
    self.token = Digest::SHA1.hexdigest([Time.now, rand].join)
  end
  
  def set_expiration
    self.expiration = 1.month.from_now
  end
  
end