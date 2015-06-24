# @author = Patrick
class Settings

  # Includes
  include ActionView::Helpers::TextHelper

  # Constants in SCREAMING_SNAKE_CASE
  NGINX_CONFIG_REGEX = /(server) ((?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))(:.+)/
  CONFIG_PATH = "/etc/nginx/sites-enabled/config"
  
  # Attribute macros
  attr_accessor :config_file, :formatted_config_file, :servers_nginx_containers, :servers_gui_containers
  
  def initialize
    @servers_nginx_containers = get_servers(get_containers(ENV["nginx_image"]))
    @servers_gui_containers = get_servers(get_containers(ENV["gui_image"]))
    @config_file = read_local_config_file
    @formatted_config_file = format_config_file
  end

  def get_containers(name)
    Container.all.where("state ilike '%\"Running\"=>true%'").where(:image => name)
  end

  def get_servers(container_list)
    servers_containers = {}
    container_list.each { |container|
      if servers_containers[Server.find(container.server_id)] == nil
        servers_containers[Server.find(container.server_id)] = [container.id]
      else
        servers_containers[Server.find(container.server_id)] = servers_containers[Server.find(container.server_id)].push(container.id)
      end
    }
    servers_containers
  end

  def read_local_config_file
    File.open(Rails.root.join('tmp', 'config'), 'rb') do |file|
      @config_file = file.read 
    end
    @config_file
  end

  def get_config_file_from_server
    @servers_nginx_containers.map { |server, containers| 
      Net::SSH.start( server.host, server.user, :password => server.password) do|ssh|
        @config_file = ssh.exec!("docker exec #{containers.first} cat #{CONFIG_PATH}")
      end
    }
    NginxService::create_config_file(@config_file)
  end

  def format_config_file
    @formatted_config_file = simple_format(@config_file)
    @servers_gui_containers.each { |server, containers|
      @formatted_config_file = @formatted_config_file.gsub("server #{server.host}", "server <span class='green'>#{server.host}</span>")
    }
    @formatted_config_file.gsub!(NGINX_CONFIG_REGEX, '\1 <span class="red">\2</span> \3')
    @formatted_config_file
  end

  def edit_config_file
    upstream = "upstream website {\n    least_conn;\n"
    @servers_gui_containers.each { |s, containers|
      containers.each {|c|
        upstream += "    server #{s.host}:#{Container.find(c).host_port};\n"
      }
    }
    @config_file.gsub!(/upstream.+/m, upstream+"}")
  end

  def update
    edit_config_file
    servers_nginx_containers.each { |server, containers|
      NginxService::config.perform(server, containers.first, @config_file)
    }
  end
end

