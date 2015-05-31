module ContainersHelper

	def servers_select_collect
		servers = Server.all.collect {|s| [ s.name, s.id ] }
	end

    def images_select_collect
        images = Image.all.collect {|i| [ i.base_image, i.id ] }
    end
	def start_container(container)
		
	end
end
