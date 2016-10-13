module ArtistHelper
  def carousel_photos photos
    limit = photos.size / 2

    photos.order('RANDOM()').
    limit(limit).each_slice(4).to_a
  end
end