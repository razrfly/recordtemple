module RecordsHelper

  def condition_formatter(condition)
    rules = {'_' => ' ', 'plus' => '+'}

    condition.gsub(/_|plus/, rules)
  end
end
