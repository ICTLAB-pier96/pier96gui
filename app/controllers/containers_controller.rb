  class ContainersController < ApplicationController

  def new
    @container = Container.new
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
    
    Docker::Image.create("fromImage" => "#{image.repo}/#{image.image}")
    creation_args["Image"] = "#{image.repo}/#{image.image}" 
    container_arguments_attributes = form_params["container_arguments_attributes"]
    unless container_arguments_attributes.nil?
      container_arguments_attributes.each do |a|
        b = Hash(a[1])
        creation_args["#{b["name"]}"] = "#{b["value"]}"
      end
    end

    puts creation_args
    
    begin
      c = Docker::Container.create(creation_args)
      @container = Container.parse_container(c.json, server)
      redirect_to @container
    rescue Docker::Error::DockerError => e
      puts e
      redirect_to({action: :index}, :alert => "An error occured while trying to create the container... Verify your image exists in the repository.")
    end
  end

  def index
    Container.update_all_containers
    @containers = Container.all
    respond_to do |format|
      format.html
      format.json{
        render :json => @containers.as_json(:except => [:state])
      }
    end
  end

  def show
    @container = Container.find(params[:id])
    @server = Server.find(@container.server_id)
    respond_to do |format|
      format.html
      format.json{
        render :json => @containers.as_json(:except => [:state])
      }
    end
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

  def migrate
    server_id = params[:server_id]
    container_id = params[:id]
    worker = ContainerMigrateWorker.new(server_id, container_id)
    worker.migrate_container_to_server
    flash[:notice] = "Container' is currently being migrated, this could take a while."
    redirect_to action: :index
  end

  def refresh
  ContainerStatusWorker.perform
  flash[:notice] = "Containers' status is currently being checked, this could take a while."
  redirect_to action: :index
  end

  private
      def container_params
          params.require(:container).permit(:command, :image_id, :name, :server_id, :local_port, :host_port, container_arguments_attributes: [:name, :value])
      end
end