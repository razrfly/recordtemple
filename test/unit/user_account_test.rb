require 'test_helper'

class UserAccountTest < ActiveSupport::TestCase
  def test_should_be_valid
    assert UserAccount.new.valid?
  end
end
