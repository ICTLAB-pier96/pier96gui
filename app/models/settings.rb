class Settings
  include ActionView::Helpers::TextHelper
  def initialize
    @servers_nginx_containers = get_servers(get_containers("nginx"))
    @servers_gui_containers = get_servers(get_containers("pier96/gui"))
    @config_file = read_config_file
    @formatted_config_file = format_config_file
  end

  attr_accessor :config_file, :formatted_config_file, :servers_nginx_containers, :servers_gui_containers
  def get_containers(name)
    Container.all.where(:image => name)
  end

  def get_servers(container_list)
    servers_containers = {}
    container_list.each do |c|
      if servers_containers[Server.find(c.server_id)] == nil
        servers_containers[Server.find(c.server_id)] = [c.id]
      else
        servers_containers[Server.find(c.server_id)] = servers_containers[Server.find(c.server_id)].push(c.id)
      end
    end
    servers_containers
  end

  def read_config_file
    @servers_nginx_containers.map{|server, containers| 
      Net::SSH.start( server.host, server.user, :password => server.password) do|ssh|
        @config_file = simple_format(ssh.exec!("docker exec #{containers.first} cat /etc/nginx/sites-enabled/config"))
      end
    }
    @config_file
  end

  def format_config_file
    @formatted_config_file = @config_file
    @servers_gui_containers.each do |server,containers|
      @formatted_config_file = @formatted_config_file.gsub("server #{server.host}", "server <span class='green'>#{server.host}</span>")
    end
    @formatted_config_file.gsub!(/(server) ((?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))(:.+)/, '\1 <span class="red">\2</span> \3')
  end

  def update
    servers_nginx_containers.each do |server, containers|
      NginxEditConfigWorker.perform(server, containers.first, @config_file)
    end
  end
end

