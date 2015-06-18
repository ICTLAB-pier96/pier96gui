class ContainersController < ApplicationController
    include ContainersDeployHelper

    def new
    end

    def create
        require 'docker'
        form_params = container_params
        server = Server.find(form_params["server_id"])
        image = Image.find(form_params["image_id"])
        Docker.url = "tcp://"+server.host+":5555/"
        creation_args = {}
        creation_args["ExposedPorts"] = {"#{form_params["local_port"]}/tcp" => ""}
        creation_args["HostConfig"] = {"PortBindings" => {"#{form_params["local_port"]}/tcp" => [{"HostPort" => "#{form_params["host_port"]}"}]}}
        creation_args["Cmd"] = form_params["command"].split(" ")
        creation_args["Image"] = "#{image.repo}/#{image.image}" 
        # creation_args["HostName"] = form_params["name"] 
        c = Docker::Container.create(creation_args)

        @container = Container.parse_container(c.json, server)

        redirect_to @container
    end

    def destroy
        @container = Container.find(params[:id])
        @container.destroy
        redirect_to action: :index
    end

    def stop
        @container = Container.find(params[:id])
        @container.stop
        redirect_to action: :index
    end

    def pause
        @container = Container.find(params[:id])
        @container.pause
        redirect_to action: :index
    end

    def unpause
        @container = Container.find(params[:id])
        @container.unpause
        redirect_to action: :index
    end

    def restart
        @container = Container.find(params[:id])
        @container.restart
        redirect_to action: :index
    end

    def start
        @container = Container.find(params[:id])
        @container.start
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

    def refresh
      ContainerStatusWorker.delay.perform
      flash[:notice] = "Containers' status is currently being checked, this could take a while."
      redirect_to action: :index
    end

    private
        def container_params
            params.require(:container).permit(:command, :image_id, :name, :server_id, :local_port, :host_port)
        end
end