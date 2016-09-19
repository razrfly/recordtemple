module SearchQueryHelper
  extend ActiveSupport::Concern

  included do
    after_action :remember_search_query_link, only: [:index]
    before_action :clear_search_query_link, except: [:show]
  end

  private

  def clear_search_query_link
    session[:last_search_query].try(:clear)
  end

  def remember_search_query_link
    session[:last_search_query] = request.url
  end
end
