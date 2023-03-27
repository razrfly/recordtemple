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
          if photo.url.present?
            puts "#{record.id}, #{record.title}, #{photo.url}, #{photo.image_filename}"
            MigrateAssetJob.perform_later('photo',photo.id)
          end
        else
          #puts "Skipping photo for #{record.title} - already present as #{photo.image_filename}"
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
          if song.url.present?
            puts "#{record.id}, #{record.title}, #{song.url}, #{song.audio_filename}"
            MigrateAssetJob.perform_later('song',song.id)
          end
        else
          #puts "Skipping audio for #{record.title} - already present as #{song.audio_filename}"
        end
      end
    end
  end

  desc "Import record images from cache"
  task photos_inline: :environment do
    Photo.where.not(url: nil).each do |photo|
      # find the record and without images
      record = photo.record
      if record.present?
        # enure there are no images or the image is not already present
        if record.images.blank? || record.images.map { |blob| blob.filename.to_s }.exclude?(photo.image_filename)
          puts "#{record.id} - #{record.title} - #{photo.url} - #{photo.image_filename}"
          file = URI.open(photo.url)
          record.images.attach(io: file, filename: photo.image_filename)
        end
      end
    end
  end

end