class ServersController < ApplicationController
  respond_to :html, :json

  def new
  end

  def create
    @server = Server.new(server_params)
    @server.save

    redirect_to @server
  end

  def index
    @servers = Server.all
    puts @servers.inspect
    respond_to do |format|
      format.html
      format.json{
        render :json => @servers.to_json(:only => [ :id, :name, :host ])
      }
    end
    
  end
  
  def destroy
    @server = Server.find(params[:id])
    @server.destroy

    redirect_to action: :index
  end

  def refresh
    ServersStatusWorker.perform
    redirect_to action: :index
  end

  def setup
    ServerSetupWorker.perform(params[:id])
    redirect_to action: :index
  end

  def show
    @server = Server.find(params[:id])
    respond_to do |format|
      format.html
      format.json{
        render :json => @server.to_json(:only => [ :id, :name, :host ])
      }
    end
  end

  private
    def server_params
      params.require(:server).permit(:name, :host, :user, :password)
    end
end
