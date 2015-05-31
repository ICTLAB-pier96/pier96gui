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
      setup = check_server(server)
      server.setup = false
      if setup.fetch(:server_status)
        server.status = true
        if setup.fetch(:docker_status)
          server.setup_info = "Docker is correctly installed"
          if setup.fetch(:daemon_status)
            server.setup_info += " and the daemon is running on port :5555"
            server.setup = true
          else 
            server.setup_info += " but the daemon is not running on port :5555"
          end
        end
      else
        server.status = false
        server.setup_info = "Server is offline"
      end
      server.save
    end
  end
  
  def destroy
    @server = Server.find(params[:id])
    @server.destroy

    redirect_to action: :index
  end

  def check_server(server)
    @server_status = false
    @docker_installed = false
    @daemon_running = false

    begin
      Net::SSH.start( server.host, server.user, :password => server.pass, :timeout => 5) do|ssh|
        output = ssh.exec!("echo true")
        @server_status = (output === "true\n")
        server.setup_info = ""
        check_docker = ssh.exec!("dpkg-query -l docker.io")
        @docker_installed = !check_docker.match(/docker.io /).nil?
        check_connections = ssh.exec!("netstat -tunlp")
        @daemon_running = !check_connections.match(/#{Regexp.quote(server.host)}:5555.+0.0.0.0:\*.+LISTEN.+\b\/docker/).nil?
      end
    rescue => error
        puts error.message
        server.setup_info = "Server is offline"
    end
    {:server_status => @server_status, :docker_status => @docker_installed, :daemon_status => @daemon_running}
  end

  def setup
    @server = Server.find(params[:id])
    aap = check_server(@server)
    begin
      Net::SSH.start( @server.host, @server.user, :password => @server.pass ) do|ssh|
        if aap.fetch(:docker_status)
          unless aap.fetch(:daemon_status)
            ssh.open_channel do |channel|
                channel.exec("killall -9 docker; rm /var/run/docker.pid; nohup docker -H tcp://#{@server.host}:5555 -H unix:///var/run/docker.sock -d > foo.out 2> foo.err < /dev/null &") do |ch, success|
              end
            end
          end
        else
          output = ssh.exec!("apt-get install -y docker.io")
        end
      end
    rescue => error
      puts error.message
    end
    redirect_to @server
  end

  def show
    @server = Server.find(params[:id])
  end

  private
    def server_params
      params.require(:server).permit(:name, :host, :user, :pass)
    end
end
