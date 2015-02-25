namespace :audio do
  desc "migrate to refile"
  task :migrate_to_refile => :environment do
    Song.where(:audio_id => nil).find_each do |song|
      print "Processing song ##{song.id}..."
      begin
        open(song.mp3.s3_object.url_for(:read, :secure => true, :expires => 10.minutes), 'rb') do |file|
          song.audio = file
          song.save
        end
      rescue
        puts " Failed!"
        next
      end
      puts " Done!"
    end
  end

  desc "fill image_content_type (audio/mpeg)"
  task :migrate_content_type => :environment do
    Song.find_each do |song|
      song.update_column(:audio_content_type, 'audio/mpeg')
    end
    puts " Done!"
  end

  desc "copy audio size to db"
  task :copy_size => :environment do
    print "Processing song "
    Song.find_each do |song|
      print "SONG ##{song.id} "
      begin
        song.update_column(:audio_size, song.audio.size)
        puts 'OK'
      rescue
        puts 'FAILED!'
      end
    end
    puts " Done!"
  end

  desc "copy file_name"
  task :copy_filename => :environment do
    Song.find_each do |song|
      song.update_column(:audio_filename, song.mp3_file_name)
    end
    puts " Done!"
  end

end
