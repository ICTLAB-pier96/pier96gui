class Container < ActiveRecord::Base
	
	has_many :container_arguments
	accepts_nested_attributes_for :container_arguments

	attr_accessor :image_id
	
	require 'docker'
	##
	#Instance methods
	##
	#Overrides ActiveRecord's destroy method to also destroy the serverside container
	def destroy
		begin
			container = find_self_on_server
			container.delete(:force => true)
		rescue 
		    puts "container not found, deleting db entry"
		end
		super
	end

	def stop
		container = find_self_on_server
		container.kill
		Container.update_single_container(self.id,  Server.find(self.server_id))
	end

	def pause
		container = find_self_on_server
		container.pause
		Container.update_single_container(self.id,  Server.find(self.server_id))
	end

	def unpause
		container = find_self_on_server
		container.unpause
		Container.update_single_container(self.id,  Server.find(self.server_id))
	end

	def restart
		container = find_self_on_server
		container.restart
		Container.update_single_container(self.id,  Server.find(self.server_id))
	end

	def start
		container = find_self_on_server
		container.start
		Container.update_single_container(self.id,  Server.find(self.server_id))
	end

	def find_self_on_server
		server = Server.find(self.server_id)
		Docker.url = "tcp://#{server.host}:5555"
		container = Docker::Container.get(self.id)
		container
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
