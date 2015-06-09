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
        Container.update_all_containers
        @containers = Container.all
    end
    def show
        @container = Container.find(params[:id])
        @server = Server.find(@container.server_id)
    end

    private
        def container_params
            params.require(:container).permit(:name, :server_id, :image_id, :host_port, :local_port, :description)
        end
end