class ContainersController < ApplicationController
    include ContainersDeployHelper

    def new
    end

    def create
    	@container = Container.new(container_params)
    	@container.save


        ContainersDeployHelper.deploy(:dir => "public/rails", :image => "rails", :host => "188.166.29.77", :git_clone => {:name => "rails", :repo => "https://github.com/ICTLAB-pier96/pier96gui.git"}, :c_args => {"ExposedPorts" => { "3000/tcp" => {} }, "PortBindings" => { "3000/tcp" =>[{ "HostPort" => "8080" }] }})

    	redirect_to action: :index

    end

    def index
    	@containers = Container.all

    	@containers.each do |container|

    	end
    end
    def show
        @container = Container.find(params[:id])
    end

    private
    	def container_params
    		params.require(:container).permit(:name,:server_id, :image_id, :description)
    	end
end
