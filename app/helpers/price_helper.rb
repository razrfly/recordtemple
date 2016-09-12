module PriceHelper
  def price_header price
    "#{price.artist_name}, #{price.label_name}"
  end
end