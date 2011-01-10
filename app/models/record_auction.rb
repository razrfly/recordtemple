class RecordAuction
  include Ebay
  include Ebay::Types
  
  def self.list_new
    ebay = Api.new
    
    item = Item.new( :primary_category => Category.new(:category_id => 306),
             :title => 'Ruby eBay API Test Listing',
             :description => 'Welcome!',
             :location => 'Amarillo TX',
             :start_price => Money.new(1200, 'USD'),
             :quantity => 1,
             :listing_duration => 'Days_7',
             :country => 'US',
             :currency => 'USD',
             :payment_methods => ['VisaMC', 'PersonalCheck'],
             :attribute_sets => [
               AttributeSet.new(
                 :attribute_set_id => 2919,
                 :attributes => [ 
                   Attribute.new(
                     :attribute_id => 10244, 
                     :values => [ Val.new(:value_id => 10425) ]
                   ) 
                  ]
               )
             ],
             :shipping_details => ShippingDetails.new(
               :shipping_service_options => [
                 ShippingServiceOptions.new(
                  :shipping_service_priority => 2, # Display priority in the listing
                  :shipping_service => 'UPSNextDay',
                  :shipping_service_cost => Money.new(1000, 'USD'),
                  :shipping_surcharge => Money.new(299, 'USD')
                 ),
                 ShippingServiceOptions.new(
                  :shipping_service_priority => 1, # Display priority in the listing
                  :shipping_service => 'UPSGround',
                  :shipping_service_cost => Money.new(699, 'USD'),
                  :shipping_surcharge => Money.new(199, 'USD')
                 )
               ],
               :international_shipping_service_options => [ 
                 InternationalShippingServiceOptions.new(
                   :shipping_service => 'USPSPriorityMailInternational', 
                   :shipping_service_cost => Money.new(2199, 'USD'), 
                   :shipping_service_priority => 1,
                   :ship_to_location => 'Europe'
                )
               ]
             )       
    			 )
    
     begin
       response = ebay.add_item(:item => item)               
       puts "Adding item"
       puts "eBay time is: #{response.timestamp}"

       puts "Item ID: #{response.item_id}"
       puts "Fee summary: "
       response.fees.select{|f| !f.fee.zero? }.each do |f|
         puts "  #{f.name}: #{f.fee.format(:with_currency)}"
       end
     rescue Ebay::RequestError => e
       e.errors.each do |error|
         puts error.long_message
       end
     end
    
  end
  
end