#require 'open-uri'

namespace :import do
  desc "Import record images from cache"
  task photos: :environment do
    Photo.all.each do |photo|
      # find the record and without images
      record = photo.record
      if record.present? && record.images.blank?
        puts "Queuing photo for #{record.title}"
        MigrateAssetJob.perform_later('photo',photo.id)
        # begin
        #   file = URI.open(photo.url)
        #   record.images.attach(io: file, filename: photo.image_filename)
        # rescue => exception
        #   puts "Error #{exception} importing photo for #{record.id}"
        # end

      end
    end
  end

  desc "Import songs from cache"
  task songs: :environment do
    Song.all.each do |song|
      # find the record and without images
      record = song.record
      if record.present? && record.songs.blank?
        puts "Queuing audio for #{record.title}"
        MigrateAssetJob.perform_later('song',song.id)
        # begin
        #   file = URI.open(song.url)
        #   record.songs.attach(io: file, filename: song.audio_filename)
        # rescue => exception
        #   puts "Error #{exception} importing audio for #{record.id}"
        # end

      end
    end
  end

end