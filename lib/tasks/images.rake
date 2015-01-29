namespace :images do
  desc "migrate to refile"
  task :migrate_to_refile => :environment do
    Photo.where(:image_id => nil).find_each do |photo|
      print "Processing photo ##{photo.id}..."
      begin
        open(photo.data(:original), 'rb') { |file| photo.image = file; photo.save }
      rescue
        next
      end
      puts " Done!"
    end
  end
end
