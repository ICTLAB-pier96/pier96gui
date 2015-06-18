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

	def self.update_single_container(id, s)
		require 'docker'	
		if s.daemon_status
			Docker.url = "tcp://"+ s.host + ":5555"
			result = Docker::Container.get(id)
			Container.parse_container(result.json, s)
		end
	end
end