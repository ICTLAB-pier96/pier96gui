# @author = Patrick
# NginxService is a module that takes care of everything concerning the nginx loadbalancer
module NginxService
  # Config is a module that has the functionality needed to take care of the configuration
  module Config
    # all methods are class methods
    module_function
    
    # This method should be called to start the process of updating the config file on the servers
    # * *Args*    :
    #   - +progress_id+ -> ID of the ProgressBar is needed to give feedback of the process
    def update(progress_id)
      Thread.new {
        @progress = ProgressBar.find(progress_id)
        @progress.set_max(100)

        settings = Settings.new
        settings.edit_config_file

        total_containers = 0
        containers_per_server = settings.servers_nginx_containers
        containers_per_server.map{ |server, containers| total_containers += containers_per_server.size}
        
        create_config_file(settings.config_file)

        containers_per_server.each { |server, containers|
          containers.each { |container|
            push_config_file(server, container)
            reload_nginx(server, container)
            puts total_containers
            @progress.increment(100/ total_containers)
          }
        }
      }
    end

    # This method creates a local file and writes the config_file to it
    # * *Args*    :
    #   - +config_file+ -> string containing the content of the config file
    def create_config_file(config_file)
      File.open(Rails.root.join('tmp', 'config'), 'wb') do |file|
          file.write(config_file)
      end
    end

    # This method pushes the config file to the server, and then pushes it to the nginx container
    # * *Args*    :
    #   - +server+ -> server containing the nginx container
    #   - +container_id+ -> ID of the nginx container
    def push_config_file(server, container_id)
      require 'net/scp'
      Net::SCP.start(server.host, server.user, :password => server.password ) do |scp|
        scp.upload(Rails.root.join('tmp', 'config').to_s,"config")
      end
      Net::SSH.start( server.host, server.user, :password => server.password) do|ssh|
        ssh.exec!("cp config /var/lib/docker/aufs/mnt/#{container_id}/etc/nginx/sites-enabled/config")
        ssh.exec!("rm config")
      end
    end


    # This method logs in to the server, and reload the nginx service inside the nginx container
    # * *Args*    :
    #   - +server+ -> server containing the nginx container
    #   - +container_id+ -> ID of the nginx container
    def reload_nginx(server, container_id)
      Net::SSH.start( server.host, server.user, :password => server.password) do|ssh|
          ssh.exec!("docker exec #{container_id} service nginx reload")
      end
    end
  end
end
