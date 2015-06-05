class ContainersController < ApplicationController
    include ContainersDeployHelper

    def new
    end

    def create
        @container = Container.new(container_params)
        @container.save

        ContainersDeployHelper.deploy(@container)

        redirect_to @container
    end

    def destroy
        @container = Container.find(params[:id])
        @container.destroy

        redirect_to action: :index
    end

    def index
        @containers = Container.all

        @containers.each do |container|

        end
    end
    def show
        @container = Container.find(params[:id])
        @image = Image.find(@container.image_id)
        @server = Server.find(@container.server_id)
    end


    private
        def container_params
            params.require(:container).permit(:name, :server_id, :image_id, :host_port, :local_port, :description)
        end
end