class ContainersController < ApplicationController
    def new
    end

    def create
    	@container = Container.new(container_params)

    	@container.save
    	redirect_to @container
    end

    def index
    	@containers = Container.all

    	@containers.each do |container|

    	end
    end

    private
    	def container_params
    		params.require(:container).permit(:name,:server_id, :image, :description)
    	end
end
