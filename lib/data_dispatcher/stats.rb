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
  puts "\n\n#{'*' * 40}\n\n"
  puts "\tParsed Data\n"
  puts "Missing labels:                #{missing_cached_label[:parsed]}"
  puts "Missing details:               #{missing_detail[:parsed]}"
  puts "Missing price low:             #{missing_price_low[:parsed]}"
  puts "Missing price high:            #{missing_price_high[:parsed]}"
  puts "Missing year begin:            #{missing_yearbegin[:parsed]}"
  puts "Missing year end:              #{missing_yearend[:parsed]}"
  puts "Missing footnote:              #{missing_footnote[:parsed]}"
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
