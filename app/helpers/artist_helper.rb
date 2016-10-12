module ArtistHelper
  def carousel_photos photos
    method =
      photos.size.between?(4,7) ? "each_cons" : "each_slice"

    photos.order('RANDOM()').
    limit().send(method, 4).to_a
  end
end