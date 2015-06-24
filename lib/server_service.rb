# @author = Patrick
# ServerService is a global module that combines other modules concerning servers
module ServerService
  # Status is a module that has the functionality needed to check the status of the servers
  module Status
    # all methods are class methods
    module_function

    # This method should be called to update the status of all the available servers
    # If everything goes well, the status attributes of the models should be updated 
    # * *Args*    :
    #   - +progress_id+ -> ID of the ProgressBar is needed to give feedback of the process
    def update_status_for_all_servers(progress_id)
      Thread.new {
        @progress_bar = ProgressBar.find(progress_id)
        @servers = Server.all
        @progress_bar.set_max(@servers.size)
        loop_through_servers
      }
    end

    

    # This method loops through all servers and
    # calls the methods 'get_daemon_status' and 'get_server_status' on them
    # Increment progress_bar by 1 after every iteration
    def loop_through_servers
        @servers.each { |server|
          with_error_handling(:daemon_status, server) { server.get_daemon_status }
          @progress_bar.increment(0.5)
          with_error_handling(:status, server) { server.get_server_status }
          @progress_bar.increment(0.5)
        }
    end

    # This method captures exceptions
    # It rescues the StandardError exceptions
    # * *Args*    :
    #   - +symbol+ -> symbol needs to be a status attribute of the server, if an exception occurs, the status of the server will be false
    # * *Returns* :
    #   - Nothing 
    # * *Raises* :
    #   - StandardErrors -> server status will be set to false if it catches an exception
    def with_error_handling(symbol, server)
      yield
    rescue => exception
      puts exception.message
      server[symbol] = false
    end
  end

  # Setup is a module that has the functionality to setup the server based on the OS
  # Since there are a lot of different linux distributions it is not been tested on all versions
  # Setup works for this distributions: Ubuntu 14+, Debian 8, CentOS 7
  module Setup
    # all methods are class methods
    module_function

    # This method creates a ssh connection and checks if it has docker installed and the daemon is running correctly
    #
    # * *Args*    :
    #   - +server+ -> needs one server instance
    # * *Returns* :
    #   - Nothing 
    # * *Raises* :
    #   - Nothing
    def setup_server(server_id, progress_id)
      Thread.new {
        server = Server.find(server_id)
        @progress_bar = ProgressBar.find(progress_id)
        @progress_bar.set_max(4)

        Net::SSH.start( server.host, server.user, :password => server.password) do|ssh|
          os = ssh.exec!("cat /etc/*release | tr -s '=' $'\t' |grep PRETTY_NAME |cut -f2")
          @progress_bar.increment(1)
          server.os = os

          cmd = case os
          # TODO: Figure out a way to see if docker is installed on other operating systems
          when /CentOS/
            "yum list installed docker"
          when /Ubuntu/, /Debian/
            "dpkg-query -l docker.io"
          else 
            "dpkg-query -l docker"
          end

          check_docker = ssh.exec!(cmd)
          @progress_bar.increment(1)
          
          server.install_docker(ssh) if check_docker.match(/docker/).nil?
          @progress_bar.increment(1)

          server.run_docker_daemon(ssh) unless server.daemon_status
          @progress_bar.increment(1)
        end
      }
    end
  end
end