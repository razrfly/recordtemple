namespace :load do

  desc "Get images for new hostels"
  task :s3 => :environment do
    tmp = "public"

    Mugshot.find(:all, :conditions => ['parent_id IS NULL AND id > 5330']).each do |c|
      puts c.public_filename.downcase
      Photo.create(:record_id => c.record_id, :data => File.open(tmp+c.public_filename))
    end

  end
  
end