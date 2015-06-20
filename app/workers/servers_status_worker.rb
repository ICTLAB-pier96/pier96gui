# @author = Patrick
# ServerStatusWorker is a process that should run in the background, it is used to check the status of the server and daemon
class ServersStatusWorker

  require 'net/http'
  require 'json'


  class << self
    def perform
      puts "test"
      servers = Server.all
      loop_through_servers(servers)
    end

    def loop_through_servers(servers)
      @statuses = {}
        Thread.new{
          servers.each do |server|
            with_io_error_handling(:deamon_status, server) {get_daemon_status(server)}
            with_io_error_handling(:status, server) {get_server_status(server)}
          end
        }.join
        return @statuses
    end


    def get_server_status(server)
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
    end

    def get_daemon_status(server)
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
    end


    def with_io_error_handling(symbol, server)
      yield
    rescue Timeout::Error
      puts "Timeout::Error: Can't connect to server."
      server.update_attributes(symbol => false)
    rescue Net::SSH::AuthenticationFailed
      puts "Net::SSH::Authenticationfailed:: Incorrect user/password combination."
      server.update_attributes(symbol => false)
    rescue Errno::ETIMEDOUT
      puts "Errno::ETIMEDOUT: Connection timeout."
      server.update_attributes(symbol => false)
    rescue Errno::ECONNREFUSED
       puts "Errno::ECONNREFUSED: Server does open the connection."
       server.update_attributes(symbol => false)
    rescue SocketError
      puts "SocketError: Something unexpected happened."
      server.update_attributes(symbol => false)
    end
  end
end
