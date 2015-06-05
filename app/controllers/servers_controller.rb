class ServersController < ApplicationController


  def new
  end

  def create
    @server = Server.new(server_params)
    @server.save

    redirect_to @server
  end

  def index
    require 'rubygems'
    require 'net/ssh'
    @servers = Server.all
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

  def show
    @server = Server.find(params[:id])
  end

  private
    def server_params
      params.require(:server).permit(:name, :host, :user, :password)
    end
end
