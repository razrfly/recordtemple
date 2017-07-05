module Stats
 def fire_stats!
  puts "\n\n#{'*' * 40}\n\n"
  puts "\tOriginal Data\n\n"
  puts "Missing labels:                #{missing_cached_label[:original]}"
  puts "Missing details:               #{missing_detail[:original]}"
  puts "Missing price low:             #{missing_price_low[:original]}"
  puts "Missing price high:            #{missing_price_high[:original]}"
  puts "Missing year begin:            #{missing_yearbegin[:original]}"
  puts "Missing year end:              #{missing_yearend[:original]}"
  puts "Missing footnote:              #{missing_footnote[:original]}"
  puts "Total original prices:         #{@@original_prices['total']}"
  puts "\n\n#{'*' * 40}\n\n"
  puts "\tParsed Data\n\n"
  puts "Missing labels:                #{missing_cached_label[:parsed]}"
  puts "Missing details:               #{missing_detail[:parsed]}"
  puts "Missing price low:             #{missing_price_low[:parsed]}"
  puts "Missing price high:            #{missing_price_high[:parsed]}"
  puts "Missing year begin:            #{missing_yearbegin[:parsed]}"
  puts "Missing year end:              #{missing_yearend[:parsed]}"
  puts "Missing footnote:              #{missing_footnote[:parsed]}"
  puts "Total:                         #{@@total_with_detail + @@total_with_missing_detail}"
  puts "\n\n#{'*' * 40}\n\n"
  puts "\tParsed prices without detail\n\n"
  puts "The same attributes:           #{@@price_with_missing_detail_and_same_attributes}"
  puts "Skipped - different years:     #{@@price_with_missing_detail_and_different_years}"
  puts "To update:                     #{@@price_with_missing_detail_to_update}"
  puts "Not found prices:              #{@@price_with_missing_detail_not_found}"
  puts "Total with missing detail:     #{@@total_with_missing_detail}"
  puts "\n\n#{'*' * 40}\n\n"
  puts "\tParsed prices with detail\n\n"
  puts "The same attributes:           #{@@price_with_detail_and_same_attributes}"
  puts "Skipped - different years:     #{@@price_with_detail_and_different_years}"
  puts "To update:                     #{@@price_with_detail_to_update}"
  puts "Not found prices:              #{@@price_with_detail_not_found}"
  puts "Total with detail:             #{@@total_with_detail}"
  puts "\n\n#{'*' * 40}\n\n"
  puts "\tMissing artist or labels\n\n"
  puts "Artist not found:              #{@@artist_not_found}"
  puts "Label not found:               #{@@label_not_found}"
  puts "Record format not found:       #{@@record_format_not_found}"
  puts "\n\n#{'*' * 40}\n\n"
  puts "\tUpdated or created prices \n\n"
  puts "Updated prices:                #{@@updated_prices}"
  puts "Created prices:                #{@@created_prices}"
  puts "\n\n#{'*' * 40}\n\n"
  puts "Total parsed prices:           #{@@total_with_detail + @@total_with_missing_detail}"
 end

 def initialize_counters
  @@total_with_missing_detail ||= 0
  @@price_with_missing_detail_and_same_attributes ||= 0
  @@price_with_missing_detail_and_different_years ||= 0
  @@price_with_missing_detail_to_update ||= 0
  @@price_with_missing_detail_not_found ||= 0

  @@total_with_detail ||= 0
  @@price_with_detail_and_same_attributes ||= 0
  @@price_with_detail_and_different_years ||= 0
  @@price_with_detail_to_update ||= 0
  @@price_with_detail_not_found ||= 0

  @@artist_not_found ||= 0
  @@label_not_found ||= 0
  @@record_format_not_found ||= 0

  @@updated_prices ||= 0
  @@created_prices ||= 0

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

# Counters for prices without detail

def increment_total_with_missing_detail
  @@total_with_missing_detail += 1
end

def increment_price_with_missing_detail_and_same_attributes
  @@price_with_missing_detail_and_same_attributes += 1
end

def increment_price_with_missing_detail_and_different_years
  @@price_with_missing_detail_and_different_years += 1
end

def increment_price_with_missing_detail_to_update
  @@price_with_missing_detail_to_update += 1
end

def increment_price_with_missing_detail_not_found
  @@price_with_missing_detail_not_found += 1
end

# Counters for prices with detail

def increment_total_with_detail
  @@total_with_detail += 1
end

def increment_price_with_detail_and_same_attributes
  @@price_with_detail_and_same_attributes += 1
end

def increment_price_with_detail_and_different_years
  @@price_with_detail_and_different_years += 1
end

def increment_price_with_detail_to_update
  @@price_with_detail_to_update += 1
end

def increment_price_with_detail_not_found
  @@price_with_detail_not_found += 1
end

# Insertion counters
def increment_artist_not_found
  @@artist_not_found += 1
end

def increment_label_not_found
  @@label_not_found += 1
end

def increment_record_format_not_found
  @@record_format_not_found += 1
end

def increment_updated_prices
  @@updated_prices += 1
end

def increment_created_prices
  @@created_prices += 1
end

def method_missing(name, *args)
  super unless name =~ /^missing_(.*)$/

  original_prices = @@original_prices.send(:[], $1)
  parsed_prices = DataDispatcher::SOURCE_FILES.inject(0) do |result, file_name|
    sub_prices = self.class.class_variable_get(:@@prices)[file_name]
    result + sub_prices.try(:count) { |x| x.send(:[], $1).nil? }.to_i
  end

  { original: original_prices, parsed: parsed_prices }
 end

 def respond_to_missing?(name, include_private = false)
  name =~ /^missing_(.*)$/ || super
 end
end
