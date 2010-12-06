module ApplicationHelper
  
  def real_currency(number)
    number_to_currency(number, :delimiter => ".", :unit => "$", :separator => ".")
  end
  
end
