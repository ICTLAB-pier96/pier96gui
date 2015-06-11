class ContainersController < ApplicationController
    include ContainersDeployHelper

    def new
    end

    def create
        require 'docker'
        server = Server.find(container_params["server_id"])
        Docker.url = "tcp://"+server.host+":5555/"
        customargs = {}
        # customargs = {"ExposedPorts" => { "#{container_params["localport"]}/tcp" => {} }, 
                    # "PortBindings" => { "#{container_params["localport"]}/tcp" => [{ "HostPort" => "#{container_params["hostport"]}" }] }}
        customargs["Image"] = "nginx"
        customargs["Name"] = container_params["name"] 
        c = Docker::Container.create(customargs)
        c.start
        Container.parse_container(c.json, server)
        # @container = ContainersDeployHelper.deploy(container_params)
        # @container = Container.new(container_params)
        # @container.save

        # ContainersDeployHelper.deploy(@container)

        redirect_to @container
    end

    def destroy
        @container = Container.find(params[:id])
        @container.destroy
        redirect_to action: :index
    end

    def index
        # Container.update_all_containers
        @containers = Container.all
    end

    def show
        @container = Container.find(params[:id])
        @server = Server.find(@container.server_id)
    end

    private
        def container_params
            params.require(:container).permit(:command, :created, :image, :labels, :name, :state, :server_id, :local_port, :host_port, :args)
        end
end