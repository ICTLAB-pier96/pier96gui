namespace :server do
  desc "Get and update status of the servers"
  task :check_status => :environment do
    puts "Checking status..."
    ServersStatusWorker.perform
    puts "Done."
  end
end