ActiveAdmin.register Genre do
  #scope_to :current_user
  
  index do
    id_column
    #column 'Artist', :cached_artist#, :sortable => 'cached_artist'
    #column 'Label', :cached_label#, :sortable => false#, :sortable => 'cached_label'
    column :name
    column('Number of Records'){ |genre| genre.records.size.to_s }
    column('Your Value'){ |genre| number_to_currency genre.records.where(user_id: current_user.id).sum(:value).to_s }
    #column('His Value'){ |genre| genre.records.sum(:value).to_s }

    #default_actions
    #column() do |genre|
    #  a 'Show', :href => admin_records_path(genre_id_eq: genre.id)
    #  a 'Edit', :href => edit_admin_price_path(price)
    #end
  end
  
end
