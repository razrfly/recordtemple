#require 'open-uri'

namespace :import do
  desc "Import record images from cache"
  task photos: :environment do
    Photo.all.each do |photo|
      # find the record and without images
      record = photo.record
      if record.present?
        # enure there are no images or the image is not already present
        if record.images.blank? || record.images.map { |blob| blob.filename.to_s }.exclude?(photo.image_filename)
          puts "Queuing photo for #{record.title}"
          MigrateAssetJob.perform_later('photo',photo.id)
        else
          puts "Skipping photo for #{record.title} - already present as #{photo.image_filename}"
        end
      end
    end
  end

  desc "Import songs from cache"
  task songs: :environment do
    Song.all.each do |song|
      # find the record and without images
      record = song.record
      if record.present?
        if record.songs.blank? || record.songs.map { |blob| blob.filename.to_s }.exclude?(song.audio_filename)
          puts "Queuing audio for #{record.title}"
          MigrateAssetJob.perform_later('song',song.id)
        else
          puts "Skipping audio for #{record.title} - already present as #{song.audio_filename}"
        end
      end
    end
  end

end