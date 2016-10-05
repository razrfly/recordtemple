module RecordsHelper

  def slider_value_helper search_query
    if search_query.price_between.present?
      low, high = search_query.price_between.
      split(',').map &:to_i

      {'slider-value': [low, high]}
    else
      {'slider-value': [0,0]}
    end
  end
end
