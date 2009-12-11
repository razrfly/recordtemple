# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  def real_currency(number)
    number_to_currency(number, :delimiter => ".", :unit => "$", :separator => ".")
  end
end
