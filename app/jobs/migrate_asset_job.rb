require 'open-uri'

class MigrateAssetJob < ApplicationJob
  queue_as :default

  def perform(asset_type,asset_id)
    case asset_type
    when 'song'
      object = Song.find(asset_id)
    when 'photo'
      object = Photo.find(asset_id)
    else
      return
    end
    record = object.record

    if record.present?
      file = URI.open(object.url)
      if asset_type == 'song'
        record.songs.attach(io: file, filename: object.audio_filename)
      elsif asset_type == 'photo'
        record.images.attach(io: file, filename: object.image_filename)
      end
    end
  end
end
