module PriceHelper
  def price_price_range price
    price_range =
      price.price_low == price.price_high ?
      price.price_low : [price.price_low, price.price_high].join('-')

    price_range || "-"
  end

  def price_year_range price
    year_range =
      price.yearbegin == price.yearend ?
      price.yearbegin : [price.yearbegin, price.yearend].join('-')

    year_range || "-"
  end
end
