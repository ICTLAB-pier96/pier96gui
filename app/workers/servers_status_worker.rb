class ServersStatusWorker

  require 'net/http'
  require 'json'
  require 'aes'

  def self.perform
    servers = Server.all
    statusus = get_daemon_status(servers)
    offline = statusus.select { |key, value| value[:daemon_status] == false }
    after_login = login_servers(offline)
    statusus.merge!(after_login)
    update_server_attributes(statusus)
  end



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

  def self.login_servers(statusus)
    @statuses = {}
      # Thread.new{
        statusus.each do |server, status|
          # begin
          puts server.host
          puts server.user
            Net::SSH.start( server.host, server.user, :password => server.password) do|ssh|
              output = ssh.exec!("echo true")
              @statuses[server] = {:status => (output === "true\n"), :daemon_status => false}
              puts "output:"+(output === "true\n").to_s
            end
          # rescue Timeout::Error
          #   puts "Timeout::Error: Can't connect to server."
          #   @statuses[server] = {:status => false, :daemon_status => false}
          # end
        end
      # }
      return @statuses
  end

  def self.update_server_attributes(statusus)
    
    statusus.each do |server, value|
      
      server.status = value[:status]
      server.daemon_status = value[:daemon_status]
      server.storage = format_size(value[:MemTotal])
      server.os = value[:OperatingSystem]
      server.total_containers = value[:Containers]
      server.total_images = value[:Images]

      puts server.inspect
      server.save
    end
  end

  def self.format_size(s)
    prefix = %W(TB GB MB KB Bytes)
    s = s.to_f
    i = prefix.length - 1
    while s > 512 && i > 0
      s /= 1024
      i -= 1
    end
    ((s > 9 || s.modulo(1) < 0.1 ? '%d' : '%.1f') % s) + ' ' + prefix[i]
    end
end
