module PriceHelper
  def price_range price
    price.price_low == price.price_high ?
    price.price_low : [price.price_low, price.price_high].join('-')
  end

  def date_range price
    price.yearbegin == price.yearend ?
    price.yearbegin : [price.yearbegin, price.yearend].join('-')
  end
end
