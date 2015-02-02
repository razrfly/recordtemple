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
end
