ActiveAdmin.register Record do
  scope_to :current_user #unless proc{ current_user.admin? }
  #actions :index, :show#, :edit, :update
  menu :priority => 1
  
  
  controller do
    #autocomplete :artist, :name#, :full => true
    
    def new
      @record = Record.new(:price_id => params[:price_id], :user_id => current_user.id)
      # call `new!` to ensure that the rest of the action continues as normal
      new!
    end
  end
  
  scope :all, :default => true do |records|
    records.includes [:genre, :price]
  end
  #scope :LPs do |records|
  #  records.includes(:price).where(media_type.contains => 'LPs')
  #end
  scope :with_music
  scope :with_photo
  
  filter :cached_artist, :label => 'Artist'
  filter :cached_label, :label => 'Label'
  #filter :comment
  filter :comment_or_price_detail_or_price_footnote, :as => :string, :label => 'Comments'
  filter :identifier_id
  filter :value, :label => 'My Value'
  filter :price_pricehigh, :as => :numeric, :label => 'Price Guide Value (Highest)'
  filter :record_price_detail, :label => 'Detail'
  #filter :price_record_format_record_type_id, :as => :numeric, :label => 'sdfsdf'#, :as => :select, :collection => RecordType.all, :label => 'Media Format'
  #filter :price_record_format_id, :as => :select, :collection => RecordFormat.all, :label => 'Media Format Sub'
  #filter :price_record_format_id, :as => :select, :collection => RecordFormat.where(:media_id => proc{ params[:q] }), :label => 'Sub Type'
  filter :genre
  filter :condition, :as => :select, :collection => Record::CONDITIONS.each_with_index.collect { |s, i| [s.titleize, i+1] }
  filter :photos_data_file_size, :as => :numeric, :label => 'Photo File Size'
  

  
  index do
    column("Image"){|record| image_tag record.cover_photo unless record.cover_photo.blank? }
    id_column
    column 'Price id', :price_id
    #column(:name){|space| link_to space.name, manage_space_path(space) }
    column 'Artist', :cached_artist
    column 'Label', :cached_label
    column :identifier_id
    column :genre, :sortable => 'genres.name'
    #column("Media"){ |record| record.price.media_type }
    column 'Format', :record_format
    #column :notes, :sortable => false
    column('Description'){ |record| truncate(record.desc, :length => 75) }
    column :updated_at
    column('Music'){ |record| status_tag (record.songs.blank? ? 'None' : pluralize(record.songs.size, 'song')), (record.songs.blank? ? :blank : :ok) }
    column('Price', :sortable => 'value'){|record| number_to_currency record.value }
    default_actions
  end
  
  csv do
    column :id
    column('Artist'){ |record| record.cached_artist }
    column('Label'){ |record| record.cached_label }
    column :identifier_id
    column('genre'){ |record| record.genre.name }
    column('Format'){ |record| record.record_format.name }
    column('Details'){ |record| record.desc }
    column('Price'){|record| number_to_currency record.value }
    column :updated_at
    
  end
  
  show do
    
    panel "Record Details" do
      attributes_table_for record do
        row :genre
        row :value
        row :comment
        row('Condition'){ record.the_condition }
        row :identifier_id
        row :price
        row :created_at
        row :updated_at
        #row("Location"){ space.location.pretty_name }
        #row :email
        #row :phone
        #row :description
        #row("Blurb"){ markdown(space.blurb) }
      end
    end
    
    unless record.photos.blank?
      panel "Photos" do
        table_for record.photos do
          column :id
          column(){ |photo| link_to image_tag(photo.data.url(:thumb)), admin_record_photo_path(record,photo) }
          column :title
          column :data_file_name
          column :data_content_type
          column('data_file_size'){ |photo| number_to_human_size(photo.data_file_size) }
          column('image_size'){ |photo| photo.data.image_size }
          column('mega_pixels'){ |photo| number_to_human(photo.data.width*photo.data.width, :precision => 2) unless photo.data.width.blank? }
          column :position
          column :created_at
          column() do |photo|
            links = link_to icon(:arrow_right_alt1) + "View", admin_record_photo_path(record,photo), :class => "view_link"
            links += link_to icon(:pen) + "Edit", edit_admin_record_photo_path(record,photo), :class => "edit_link"
            links += link_to icon(:trash_stroke) + "Delete", admin_record_photo_path(record,photo), :method => :delete, :confirm => "Are you sure you want to delete this?", :class => "delete_link"
            links
          end
        end
      end
    end
    
    unless record.songs.blank?
      panel "Songs" do
        table_for record.songs do
          column :id
          column :title
          column :mp3_file_name
          column :mp3_content_type
          column('mp3_file_size'){ |song| number_to_human_size(song.mp3_file_size) }
          column :created_at
          column() do |song|
            links = link_to icon(:arrow_right_alt1) + "View", admin_record_song_path(record,song), :class => "view_link"
            links += link_to icon(:pen) + "Edit", edit_admin_record_song_path(record,song), :class => "edit_link"
            links += link_to icon(:trash_stroke) + "Delete", admin_record_song_path(record,song), :method => :delete, :confirm => "Are you sure you want to delete this?", :class => "delete_link"
            links
          end
        end
      end
    end

  end
  
  form do |f|
    f.inputs "Details" do
      f.input :genre, :prompt => 'Please select'
      f.input :condition, :as => :select, :collection => Record::CONDITIONS.each_with_index.collect { |s, i| [s.titleize, i+1] }, :prompt => 'Please select'
      f.input :price_id, :hint => 'Dangerous do not edit unless you know what you are doing!?!'
      f.input :user_id, :as => :hidden
      f.input :identifier_id, :as => :string
    end

    f.inputs "Freebase" do
      f.input :freebase_id, :input_html => { :class => "freebase_album" }
      f.input :freebase_id, :as => :hidden, :input_html => { :class => "freebase_album_id" }
    end
    
    f.inputs "Additional" do
      f.input :value, :as => :numeric
      f.input :comment
    end
    f.buttons

  end
  
  sidebar :price_guide, :only => [:new, :edit, :show] do
    attributes_table_for record.price do
      #row(:artist){ link_to record.artist.name, artist_path(record.artist), :class => 'artist' }
      #row(:artist){ auto_link(record.artist, :class => 'artist') }
      row :artist
      row("Artist Freebase ID"){ link_to record.artist.freebase_id, edit_admin_artist_path(record.artist), :class => 'artist_freebase_id' }
      row :label
      row :record_format
      row :detail
      row :footnote
      row :price_range
      row :date_range
      row :freebase_id
      row("Last Updated"){ record.price.bubbles.last.created_at }
    end
  end
  
  #sidebar :photos, :only => :show do
  #  table_for record.photos do# |photo|
  #    column("Photos"){ |photo| image_tag(photo.data.url(:thumb)) }
  #    #image_tag(photo.data.url)
  #  end
  #end
  
  sidebar :add_media, :only => [:show, :edit], :partial => 'media'
  
  #action_item :only => [:index, :show, :edit] do
  #  link_to "New Record", admin_prices_path
  #end
  
  #action_item :only => [:show, :edit] do
  #  link_to "Add Photos", new_admin_record_photo_path(record)
  #end
  #action_item :only => [:show, :edit] do
  #  link_to "Add Music", new_admin_record_song_path(record)
  #end
  action_item :only => [:show, :edit] do
    link_to "View Listing", artist_record_path(record.artist,record)
  end

end
