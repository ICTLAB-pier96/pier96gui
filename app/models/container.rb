class Container < ActiveRecord::Base
	##
	#Instance methods
	##
	#Overrides ActiveRecord's destroy method to also destroy the serverside container
	def destroy
		require 'docker'	
		server = Server.find(self.server_id)
		Docker.url = "tcp://#{server.host}:5555"
		container = Docker::Container.get(self.id)
		container.delete(:force => true)
		super
	end


	##
	#Class methods 
	##
	#Updates all existing and new serverside records of containers
	def self.update_all_containers
		require 'docker'	
		servers = Server.all
		containers = []
		servers.each do |s| 
			if s.daemon_status
				Docker.url = "tcp://"+ s.host + ":5555"
				s_con = Docker::Container.all(:all => false)
				puts s_con
				s_con.each do |sc|
					Container.parse_container(sc.json, s)
				end
			end
		end
	end

	##
	#updates or creates(db entry) for a single container 
	def self.update_single_container(id, s)
		require 'docker'	
		Docker.url = 's.host'+':5555'
		if s.daemon_status
			Docker.url = "tcp://"+ s.host + ":5555"
			result = Docker::Container.get(id)
			puts result.json
			Container.parse_container(result.json, s)
		end
	end

	##
	#Parses json into a valid container, does both creating and updating
	def self.parse_container(params, host)
		puts params
		parsedparams = Hash.new

		parsedparams[:id] = params["Id"]
		parsedparams[:command] = params["Command"]
		parsedparams[:created] = params["Created"]
		parsedparams[:image] = params["Config"]["Image"]
		parsedparams[:labels]= params["Labels"]
		parsedparams[:name] = params["Name"]	
		parsedparams[:state] = params["State"]["Running"]
		parsedparams[:server_id] = host.id

		params["HostConfig"]["PortBindings"].each do |p|
			parsedparams[:local_port] = p[0].partition(/\//).first
			parsedparams[:host_port] = p[1][0]["HostPort"]
		end
		
		parsedparams[:args] = ""
		params["Args"].each do |str|
			parsedparams[:args] += str + " "
		end
		id = parsedparams[:id]
		Container.exists?(id) ? (container = Container.find(id).update_attributes(parsedparams)) : (container = Container.new(parsedparams); container.save)
	end
end
