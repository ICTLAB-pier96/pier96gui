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

    @servers.each do |server|
      puts server.host
      puts server.user
      puts server.pass
      begin
        Net::SSH.start( server.host, server.user, :password => server.pass ) do|ssh|
          output = ssh.exec!("echo true")
          puts output.inspect
          server.status = (output === "true\n")
        end
      rescue => error
        puts error.message
        server.status = false
      end
    end
  end
 
  def show
    @server = Server.find(params[:id])
  end

  private
    def server_params
      params.require(:server).permit(:name, :host, :user, :pass)
    end
end
