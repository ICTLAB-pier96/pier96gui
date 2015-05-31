module ContainersHelper

	def servers_select_collect
		servers = Server.all.collect {|s| [ s.name, s.id ] }
	end

	def start_container(container)
		
	end
end
