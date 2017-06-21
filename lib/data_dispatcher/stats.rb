module Stats
 def fire_stats!
  puts "\n\n#{'*' * 40}\n\n"
  puts "\tOriginal Data\n"
  puts "Missing labels:                #{missing_cached_label[:original]}"
  puts "Missing details:               #{missing_detail[:original]}"
  puts "Missing price low:             #{missing_price_low[:original]}"
  puts "Missing price high:            #{missing_price_high[:original]}"
  puts "Missing year begin:            #{missing_yearbegin[:original]}"
  puts "Missing year end:              #{missing_yearend[:original]}"
  puts "Missing footnote:              #{missing_footnote[:original]}"
  puts "Total original prices:         #{@@original_prices['total']}"
 end

 def initialize_counters
  @@original_prices ||= {
    'cached_label' => Price.where(cached_label: [nil, '']).count,
    'detail' => Price.where(detail: [nil, '']).count,
    'price_low' => Price.where(price_low: nil).count,
    'price_high' => Price.where(price_high: nil).count,
    'yearbegin' => Price.where(yearbegin: nil).count,
    'yearend' => Price.where(yearend: nil).count,
    'footnote' => Price.where(footnote: [nil, '']).count,
    'total' => Price.count
  }
 end
end
