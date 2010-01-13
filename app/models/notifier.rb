class Notifier < ActionMailer::Base
  
  def recommendation(recommendation, record_url)
    subject    'You have a shared record to view'
    recipients recommendation.email
    from       "#{recommendation.record.user.login}@recordtemple.com"
    body       :recommendation => recommendation, :record_url => record_url
  end

end
