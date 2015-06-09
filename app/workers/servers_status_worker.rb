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
    servers = Server.all
    statusus = get_daemon_status(servers)
    offline = statusus.select { |key, value| value[:daemon_status] == false }
    after_login = login_servers(offline)
    statusus.merge!(after_login)
    update_server_attributes(statusus)
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
              @statuses[server] = JSON.parse(@response1.body, :symbolize_names => true).merge({:status => true, :daemon_status => true})
          end
        rescue Errno::ECONNREFUSED
            @statuses[server] = {:status => false, :daemon_status => false}
        rescue Timeout::Error
            puts "Timeout::Error: Can't connect to server."
            @statuses[server] = {:status => false, :daemon_status => false}
        rescue SocketError
            puts "SocketError: Something unexpected happened."
            @statuses[server] = {:status => false, :daemon_status => false}
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
  def self.login_servers(statusus)
    @statuses = {}
      Thread.new{
        statusus.each do |server, status|
          begin
            Net::SSH.start( server.host, server.user, :password => server.password) do|ssh|
              output = ssh.exec!("echo true")
              @statuses[server] = {:status => (output === "true\n"), :daemon_status => false}
            end
          rescue Timeout::Error
            puts "Timeout::Error: Can't connect to server."
            @statuses[server] = {:status => false, :daemon_status => false}
          rescue Net::SSH::AuthenticationFailed
            #  TODO: let user know that the user/pass failed to login
            puts "Net::SSH::Authenticationfailed:: Incorrect user/password combination."
            @statuses[server] = {:status => false, :daemon_status => false}
          rescue Errno::ECONNREFUSED
             puts "Errno::ECONNREFUSED: Server does open the connection."
            @statuses[server] = {:status => false, :daemon_status => false}
          rescue SocketError
            puts "SocketError: Something unexpected happened."
            @statuses[server] = {:status => false, :daemon_status => false}
          end
        end
      }
      return @statuses
  end

# This method is to update the server attributes based on the status they have.
# The argument it takes is a hash of hashes, the second hash contains the needed information about the server.
#
# * *Args*    :
#   - +statusus+ -> hash of hashes, where the keys are the servers that does not have a daemon running, the second hash contains information about the status.
# * *Returns* :
#   - Nothing
# * *Raises* :
#   - No exceptions
  def self.update_server_attributes(statusus)
    
    statusus.each do |server, value|
      
      server.status = value[:status]
      server.daemon_status = value[:daemon_status]
      server.storage = number_to_human_size(value[:MemTotal])
      server.os = value[:OperatingSystem]
      server.total_containers = value[:Containers]
      server.total_images = value[:Images]
      server.save
    end
  end
end
