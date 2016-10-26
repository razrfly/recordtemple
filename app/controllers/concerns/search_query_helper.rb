module SearchQueryHelper
  extend ActiveSupport::Concern

  included do
    after_action :remember_search_query_link, only: [:index]
    before_action :clear_search_query_link, except: [:show]
  end

  private

  def query_params
    _keys = ['records_id_null','photos_id_not_null',
      'songs_id_not_null', 'price_price_low_gteq',
      'price_price_low_gteq']

    params[:q].try(:reject) do |key, value|
      _keys.include?(key) && value == '0' || value.blank?
    end
  end

  #Just to make controllers using related records
  #search table more DRY
  def records_search_results(search_query)
    @records = search_query.result.eager_load(
      :artist, :genre, :label, :price, :photos,
      :songs, :record_format => :record_type
      ).page(params[:page])
  end

  def remember_last_search_query
    @last_search_query = session[:last_search_query]
  end

  def clear_search_query_link
    session[:last_search_query].try(:clear)
  end

  def remember_search_query_link
    session[:last_search_query] = request.url
  end
end
