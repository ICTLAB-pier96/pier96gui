# @author = Patrick
# ServerStatusWorker is a process that should run in the background, it is used to check the status of the server and daemon
class ServersStatusWorker

  require 'net/http'
  require 'json'
  require 'aes'
  require 'action_view'
  include ActionView::Helpers::NumberHelper


# This method is used to start this worker. It contains the main logic of the steps that are needed to check if a server is online.
#
# * *Args*    :
#   - None
# * *Returns* :
#   - Nothing
# * *Raises* :
#   - Nothing
  def self.perform
    puts "test"
    servers = Server.all
    get_daemon_status(servers)
    get_server_status(servers)
  end


# This method is to check if docker is correctly installed and the daemon is running.
# It iterates over the array of servers while it tries to make a http request to the daemon running
# on port :5555
#
# * *Args*    :
#   - +servers+ -> array of the servers
# * *Returns* :
#   - hash of hashes -> where the server itself is the key and the value is another hash that contains the information about the server
# * *Raises* :
#   - +Errno::ECONNREFUSED+ -> if the server is not reachable.
#   - +Timeout::Error+ -> if the server takes too long to respond back.
#   - +SocketError+ -> if something unknowns happens with ssl.
  def self.get_daemon_status(servers)
    @statuses = {}
    Thread.new{
      servers.each do |server|
        begin
          url1 = URI.parse("http://"+ server.host.gsub("http://","")+":5555/info")
          http = Net::HTTP.new(url1.host, url1.port)
          http.read_timeout = 5
          http.open_timeout = 5
          http.start do |connection|
              url2 = URI.parse(URI.encode("http://" + server.host.gsub("http://","")+":5555/info"))
              request1 = Net::HTTP::Get.new(url2.request_uri)
              @response1 = connection.request(request1)
              status =  JSON.parse(@response1.body, :symbolize_names => true)
              helper = Object.new.extend(ActionView::Helpers::NumberHelper) 
              server.update_attributes(
                :status => true,
                :daemon_status => true,
                :storage => helper.number_to_human_size(status[:MemTotal]),
                :ram_usage => status[:ram_usage],
                :os => status[:OperatingSystem], 
                :total_containers => status[:Containers],
                :total_images => status[:Images])
          end
        rescue Errno::ETIMEDOUT 
            puts "Errno::ETIMEDOUT: Connection timeout."
        rescue Errno::ECONNREFUSED
            puts "Errno::ECONNREFUSED: Connection refused."
            server.update(:daemon_status => false)
        rescue Timeout::Error
            puts "Timeout::Error: Can't connect to server."
            server.update(:daemon_status => false)
        rescue SocketError
            puts "SocketError: Something unexpected happened."
            server.update(:daemon_status => false)
        end

      end
    }.join
    return @statuses
  end

# This method is to check if the server is able to login on the server using SSH.
# If it is possible to login with SSH, it echo's true on the server to let the system know the server is running.
#
# * *Args*    :
#   - +statusus+ -> hash of hashes, where the keys are the servers that does not have a daemon running, the second hash contains information about the status.
# * *Returns* :
#   - +hash of hashes+ -> where the server itself is the key and the value is another hash that contains the information about the server
# * *Raises* :
#   - +Net::SSH::AuthenticationFailed+ -> if the user/pass combination is invalid
#   - +Errno::ECONNREFUSED+ -> if the server is not reachable.
#   - +Timeout::Error+ -> if the server takes too long to respond back.
#   - +SocketError+ -> if something unknowns happens with ssl.
  def self.get_server_status(servers)
    @statuses = {}
      Thread.new{
        servers.each do |server|
          begin
            Net::SSH.start( server.host, server.user, :password => server.password, :timeout => 5) do|ssh|
              status = ssh.exec!("echo true")
              ram_usage = ssh.exec!("free | grep Mem | awk '{print $3/($2+$7)*100.0}'")
              disk_space = ssh.exec!("df | tr -s ' ' $'\t' | grep /dev/ | cut -f4")
              
              server_load = ServerLoad.new(:server_id => server.id, :ram_usage => ram_usage.to_i).save
              helper = Object.new.extend(ActionView::Helpers::NumberHelper) 
              server.update_attributes(
                :ram_usage => ram_usage.to_i.round,
                :disk_space => helper.number_to_human_size((disk_space.to_i*1024)),
                :status => (status === "true\n"))
            end
          rescue Timeout::Error
            puts "Timeout::Error: Can't connect to server."
            server.update_attributes(:status => false)
          rescue Net::SSH::AuthenticationFailed
            #  TODO: let user know that the user/pass failed to login
            puts "Net::SSH::Authenticationfailed:: Incorrect user/password combination."
            server.update_attributes(:status => false)
          rescue Errno::ETIMEDOUT
            puts "Errno::ETIMEDOUT: Connection timeout."
            server.update_attributes(:status => false)
          rescue Errno::ECONNREFUSED
             puts "Errno::ECONNREFUSED: Server does open the connection."
             server.update_attributes(:status => false)
          rescue SocketError
            puts "SocketError: Something unexpected happened."
            server.update_attributes(:status => false)
          end
        end
      }.join
      return @statuses
  end
end
