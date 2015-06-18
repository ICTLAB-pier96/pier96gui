#  @author = Patrick
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
        image = params[:image]
        if !image.nil?
          server_ids = Container.all.where(image: image).map{|c| c.server_id}
          @servers = Server.find(server_ids)
        end
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
    ServersStatusWorker.delay.perform
    flash[:notice] = "Servers' status is currently being checked, this could take a while."
    redirect_to action: :index
  end

  def setup
    ServerSetupWorker.delay.perform(params[:id])
    flash[:notice] = "Setup is running, this could take a while."
    redirect_to action: :show
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
