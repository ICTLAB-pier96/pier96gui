namespace :container do
  desc "Get and update status of the containers"
  task :check_status => :environment do
    puts "Checking CONTAINERs..."
    ContainerStatusWorker.perform
    puts "Done."
  end
end