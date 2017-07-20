namespace :dispatcher do
  desc "Parse data from remote resources"
  task :call => :environment do
    puts 'Initiation'

    DataDispatcher.call

    puts "Done!"
  end
end
