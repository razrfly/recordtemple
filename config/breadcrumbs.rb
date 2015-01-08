crumb :root do
  link "Home", admin_root_path
end


# Artists

crumb :artists do
  link "Artists", admin_artists_path
  parent :root
end

crumb :new_artist do
  link "New", new_admin_artist_path
  parent :artists
end

crumb :show_artist do |artist|
  link artist.name, admin_artist_path(artist)
  parent :artists
end

crumb :edit_artist do |artist|
  link "Edit", edit_admin_artist_path(artist)
  parent :show_artist, artist
end


# Labels

crumb :labels do
  link "Labels", admin_labels_path
  parent :root
end

crumb :new_label do
  link "New", new_admin_label_path
  parent :labels
end

crumb :show_label do |label|
  link label.name, admin_label_path(label)
  parent :labels
end

crumb :edit_label do |label|
  link "Edit", edit_admin_label_path(label)
  parent :show_label, label
end


# Genres

crumb :genres do
  link "Genres", admin_genres_path
  parent :root
end

crumb :new_genre do
  link "New", new_admin_genre_path
  parent :genres
end

crumb :show_genre do |genre|
  link genre.name
  parent :genres
end

crumb :edit_genre do |genre|
  link "Edit", edit_admin_genre_path(genre)
  parent :show_genre, genre
end

# Record formats

crumb :record_formats do
  link "Record formats", admin_record_formats_path
  parent :root
end

crumb :new_record_format do
  link "New", new_admin_record_format_path
  parent :record_formats
end

crumb :show_record_format do |record_format|
  link record_format.name
  parent :record_formats
end

crumb :edit_record_format do |record_format|
  link "Edit", edit_admin_record_format_path(record_format)
  parent :show_record_format, record_format
end


# Record types

crumb :record_types do
  link "Record types", admin_record_types_path
  parent :root
end

crumb :new_record_type do
  link "New", new_admin_record_type_path
  parent :record_types
end

crumb :show_record_type do |record_type|
  link record_type.name
  parent :record_types
end

crumb :edit_record_type do |record_type|
  link "Edit", edit_admin_record_type_path(record_type)
  parent :show_record_type, record_type
end


# Users

crumb :users do
  link "Users", admin_users_path
  parent :root
end

crumb :new_user do
  link "New", new_admin_user_path
  parent :users
end

crumb :show_user do |user|
  link user.nickname
  parent :users
end

crumb :edit_user do |user|
  link "Edit", edit_admin_user_path(user)
  parent :show_user, user
end


# Prices

crumb :new_price do |artist|
  link "New", new_admin_artist_price_path(artist)
  parent :show_artist, artist
end

crumb :show_price do |price|
  link 'Price', admin_artist_price_path(price.artist, price)
  parent :show_artist, price.artist
end

crumb :edit_price do |price|
  link "Edit", edit_admin_artist_price_path(price.artist, price)
  parent :show_price, price
end