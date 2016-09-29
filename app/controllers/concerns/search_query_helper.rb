module SearchQueryHelper
  extend ActiveSupport::Concern

  included do
    after_action :remember_search_query_link, only: [:index]
    before_action :clear_search_query_link, except: [:show]
  end

  private

  def query_params
    _search_keys =
      ['records_id_null','photos_id_not_null', 'songs_id_not_null']

    params[:q].try(:reject) do |key, value|
      (_search_keys.include?(key) && value == '0') || value.blank?
    end
  end

  def clear_search_query_link
    session[:last_search_query].try(:clear)
  end

  def remember_search_query_link
    session[:last_search_query] = request.url
  end
end
