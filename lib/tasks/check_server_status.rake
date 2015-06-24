# @author = Patrick
namespace :server do
  desc "Get and update status of the servers"
  task :check_status => :environment do
    puts "Checking status..."
    ServerService::Status.update_status_for_all_servers(0)
    puts "Done."
  end
end