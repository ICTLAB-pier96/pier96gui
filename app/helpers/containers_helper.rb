module ContainersHelper

	def servers_select_collect
		servers = Server.all.collect {|s| [ s.name, s.id ] }
	end

  def images_select_collect
      images = Image.all.collect {|i| [ i.image, i.id ] }
  end

  def get_server(id)
  	server = Server.find(id)
  end
  
end
