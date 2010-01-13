require 'test_helper'

class NotifierTest < ActionMailer::TestCase
  test "recommendation" do
    @expected.subject = 'Notifier#recommendation'
    @expected.body    = read_fixture('recommendation')
    @expected.date    = Time.now

    assert_equal @expected.encoded, Notifier.create_recommendation(@expected.date).encoded
  end

end
