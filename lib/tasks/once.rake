namespace :fix do
    
  desc "Populate new artists table"
  task :artists => :environment do
    artists = Price.select('DISTINCT artist')
    artists.each do |artist|
      c = Artist.create(:name => artist.artist)
      puts c.name
      d = Price.find_all_by_artist(c.name)
      d.each do |r|
        r.artist_id = c.id
        r.save
      end
    end
  end
  
  desc "Populate new artists table"
  task :artists2 => :environment do
    Record.all.each do |record|
      record.artist_id = record.price.artist_id
      record.save
      puts record.price.artist
    end
  end
    
end
