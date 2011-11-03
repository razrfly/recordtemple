ActiveAdmin.register RecordFormat do
  index do
    id_column
    column :name
    column :record_type
    #column('count'){ |record_format| record_format.prices.size.to_i }
    #column(){ |record_format| link_to 'Jump', admin_prices_path('q[record_format_id_eq=31]') }
    default_actions
  end
end
