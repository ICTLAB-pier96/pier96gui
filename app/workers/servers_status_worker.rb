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
        Thread.new {
          servers.each { |server|
            with_error_handling(:daemon_status, server) { server.get_daemon_status }
            with_error_handling(:status, server) { server.get_server_status }
          }
        }.join
    end


    def with_error_handling(symbol, server)
      yield
    rescue => exception
      puts exception.message
      server.update_attributes(symbol => false)
    end
  end
end
