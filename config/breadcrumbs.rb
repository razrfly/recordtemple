crumb :root do
  link "Home", root_path
end

# This is just for create crumbs from
# any provided attributes like for ex.:
# /:artist-name-:label_name

slug_composer = ->(entity, *methods){
    slug = methods.inject([]) do |result, method|
      result << entity.send(method).presence
    end.join('-').parameterize

    slug.presence || entity.id
  }

#Records crumbs
  crumb :records do
    link "Records", records_path
  end

  crumb :new_record do
    link "New", new_record_path
    parent :records
  end

  crumb :record do |record|
    slug = slug_composer.(record, 'artist_name', 'label_name')

    link slug, record_path(record)
    parent :records
  end

  crumb :edit_record do |record|
    link "Edit", edit_record_path(record)
    parent :record, record
  end

#Labels crumbs
  crumb :labels do
    link "Labels", labels_path
  end

  crumb :label do |label|
    link label.name.parameterize, label_path(label)
    parent :labels
  end

#Artist crumbs
  crumb :artists do
    link "Artists", artists_path
  end

  crumb :artist do |artist|
    link artist.name.parameterize, artist_path(artist)
    parent :artists
  end

#Genre crumbs
  crumb :genre do |genre|
    link genre.name.parameterize, genre_path(genre)
  end

#Prices crumbs
  crumb :prices do
    link "Prices", prices_path
  end

  crumb :price do |price|
    slug = slug_composer.(price, 'cached_artist', 'cached_label')

    link slug, price_path(price)
    parent :prices
  end

#Record Types crumbs
  crumb :record_types do
    link "Record Types", record_types_path
  end

#User crumbs
  crumb :settings do
    link "Settings", settings_path
    parent :root
  end
