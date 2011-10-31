ActiveAdmin.register Record do
  scope_to :current_user #unless proc{ current_user.admin? }
  menu :priority => 1
  
  controller do
    autocomplete :artist, :name#, :full => true
  end
  
  scope :all, :default => true do |records|
    records.includes [:artist, :label, :genre]
  end
  scope :with_music
  scope :with_photo
  
  #filter :artist, :as => :string
  filter :cached_artist, :label => 'Artist'
  filter :cached_label, :label => 'Label'
  filter :comment
  filter :value, :label => 'My Value'
  filter :condition, :as => :select, :collection => Record::CONDITIONS.each_with_index.collect { |s, i| [s.titleize, i+1] }

  #filter :artist_id, :as => :number
  #filter :artist_name, :as => :autocomplete, :url => autocomplete_artist_name_records_path
  #filter :artist_name do
  #  render :partial => 'artist'
  #end
  
  index do
    column("Image"){|record| image_tag record.cover_photo unless record.cover_photo.blank? }
    #column(:name){|space| link_to space.name, manage_space_path(space) }
    column :artist, :sortable => 'artists.name'
    column :label, :sortable => 'labels.name'
    column :genre, :sortable => 'genres.name'
    column :comment, :sortable => false
    column :updated_at
    default_actions
  end
  
  form do |f|
    f.inputs "Details" do
      f.input :comment
      #f.input :artist_name, :as => :autocomplete, :url => autocomplete_artist_name_records_path
      #f.form_buffers.last << f.autocompleted_input(:product_name, url: autocomplete_product_name_orders_path, label: 'Product')
      #f.form_buffers.last << f.input(:artist_name, :as => :autocomplete, url: autocomplete_artist_name_records_path, label: 'Product')
      #f.form_buffers.last << f.autocompleted_input(:artist_name, url: autocomplete_artist_name_records_path, label: 'Product')
      #f.autocomplete_input :artist_name, autocomplete_artist_name_records_path
      #f.input :brand_name, :as => :autocomplete, :url => autocomplete_brand_name_products_path
      #f.autocomplete_field :artist_name, autocomplete_artist_name_records_path
      #f.form_buffers.last << f.autocompleted_input(:artist_name, url: autocomplete_artist_name_records_path)
      #f.input :artist_name, :as => :autocomplete#, url => autocomplete_artist_name_records_path
    end
    f.inputs "Socially Connect" do
      f.input :condition, :hint => "http://www.facebook.com/pages/1009000"
    end
    

    f.buttons

  end
end
