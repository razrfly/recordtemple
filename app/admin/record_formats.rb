ActiveAdmin.register RecordFormat do
  
#  index do
#    id_column
#    column :name
#    column :record_type
#    #column('count'){ |record_format| record_format.prices.size.to_i }
#    #column(){ |record_format| link_to 'Jump', admin_prices_path('q[record_format_id_eq=31]') }
#    default_actions
#  end
  
  
  index do
    id_column
    #column 'Artist', :cached_artist#, :sortable => 'cached_artist'
    #column 'Label', :cached_label#, :sortable => false#, :sortable => 'cached_label'
    column :name
    column :record_type
    column('Number of Records'){ |format| format.records.size.to_s }
    column('Your Value'){ |format| number_to_currency format.records.where(user_id: current_user.id).sum(:value).to_s }

    #default_actions
    #column() do |genre|
    #  a 'Show', :href => admin_records_path(genre_id_eq: genre.id)
    #  a 'Edit', :href => edit_admin_price_path(price)
    #end
  end
end
