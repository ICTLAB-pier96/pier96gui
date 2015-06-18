class Container < ActiveRecord::Base
	##
	#Instance methods
	##
	#Overrides ActiveRecord's destroy method to also destroy the serverside container
	def destroy
		require 'docker'	
		begin
			server = Server.find(self.server_id)
			Docker.url = "tcp://#{server.host}:5555"
			container = Docker::Container.get(self.id)
			container.delete(:force => true)
		rescue 
		    puts "container not found, deleting db entry"
		end
		super
	end

	def stop
		require 'docker'
		server = Server.find(self.server_id)
		Docker.url = "tcp://#{server.host}:5555"
		container = Docker::Container.get(self.id)
		container.kill
		Container.update_single_container(self.id, server)
	end

	def pause
		require 'docker'
		server = Server.find(self.server_id)
		Docker.url = "tcp://#{server.host}:5555"
		container = Docker::Container.get(self.id)
		container.pause
		Container.update_single_container(self.id, server)
	end

	def unpause
		require 'docker'
		server = Server.find(self.server_id)
		Docker.url = "tcp://#{server.host}:5555"
		container = Docker::Container.get(self.id)
		container.unpause
		Container.update_single_container(self.id, server)
	end

	def restart
		server = Server.find(self.server_id)
		Docker.url = "tcp://#{server.host}:5555"
		container = Docker::Container.get(self.id)
		container.restart
		Container.update_single_container(self.id, server)
	end

	def start
		server = Server.find(self.server_id)
		Docker.url = "tcp://#{server.host}:5555"
		container = Docker::Container.get(self.id)
		container.start
		Container.update_single_container(self.id, server)
	end

	def self.update_all_containers
		ContainerStatusWorker.delay.update_all_containers
	end

	##
	#updates or creates(db entry) for a single container 
	def self.update_single_container(id, s)
		ContainerStatusWorker.delay.update_single_container(id, s)
	end

	##
	#Parses json into a valid container, does both creating and updating
	def self.parse_container(params, host)
		parsedparams = Hash.new
		parsedparams[:id] = params["Id"]
		parsedparams[:created] = params["Created"] if params["Created"]
		parsedparams[:image] = params["Config"]["Image"] if params["Config"]["Image"]
		parsedparams[:labels]= params["Labels"] if params["Labels"]
		parsedparams[:name] = params["Name"] if params["Name"]
		parsedparams[:state] = params["State"] if params["State"]
		parsedparams[:server_id] = host.id

		if params["HostConfig"]["PortBindings"]
			params["HostConfig"]["PortBindings"].each do |p|
				parsedparams[:local_port] = p[0].partition(/\//).first
				parsedparams[:host_port] = p[1][0]["HostPort"]
			end
		end
		parsedparams[:command] = ""

		if params["Config"]["Cmd"]
			params["Config"]["Cmd"].each do |str| 
				parsedparams[:command] += str + " "
			end
		end		

		parsedparams[:args] = ""
		params["Args"].each do |str|
			parsedparams[:args] += str + " "
		end		


		id = parsedparams[:id]
		@container
		Container.exists?(id) ? 
			(@container = Container.find(id).update_attributes(parsedparams)) : 
			(@container = Container.new(parsedparams); @container.save)
		return @container
	end
end
