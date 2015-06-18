class ContainerStatusWorker
  require 'net/http'
  require 'json'
  require 'aes'
  require 'action_view'

  def self.perform
    update_all_containers
  end

  ##
  #Class methods 
  def self.update_all_containers
    require 'docker'  
    servers = Server.all
    servers.each do |s| 
      if s.daemon_status
        Docker.url = "tcp://"+ s.host + ":5555"
        all_containers = Docker::Container.all(:all => false)
        all_containers.each do |c|
          Container.parse_container(c.json, s)
        end
      end
    end
  end
end