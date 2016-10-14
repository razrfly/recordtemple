module PriceHelper
  def price_price_range(price)
    price_range = ->(price){
      price.price_low == price.price_high ?
      price.price_low : [price.price_low, price.price_high].join('-')
    }

    price.present? ? price_range.(price) : '-'
  end

  def price_year_range(price)
    year_range = ->(price){
      price.yearbegin == price.yearend ?
      price.yearbegin : [price.yearbegin, price.yearend].join('-')
    }

    price.present? ? year_range.(price) : '-'
  end
end
