class Notifier < ActionMailer::Base
  
  def recommendation(recommendation, record_url)
    subject    'Notifier#recommendation'
    recipients recommendation.email
    from       'auto-bob@recordtemple.com'
    body       :recommendation => recommendation, :record_url => record_url
  end

end
