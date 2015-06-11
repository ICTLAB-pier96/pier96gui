# ServerSetupWorker is a process that should run in the background, it tries to install docker and make sure the daemon is running.
# Since every distribution has its own commands/packages, not all are supported.
# Known working distributions:
# - Ubuntu 14.04.2
# - Debian 8
# - CentOS 7
class ServerSetupWorker

# This method is used to start this worker. It contains the main logic of the steps that are needed to check if a server is online.
#
# * *Args*    :
#   - id -> server.id 
# * *Returns* :
#   - Nothing
# * *Raises* :
#   - Nothing
  def self.perform(id)
    server = Server.find(id)
    start_connection(server)
  end


# This method creates a ssh connection and checks if it has docker installed and the daemon is running correctly
#
# * *Args*    :
#   - +server+ -> needs one server instance
# * *Returns* :
#   - Nothing 
# * *Raises* :
#   - Nothing 
  def self.start_connection(server)
    Net::SSH.start( server.host, server.user, :password => server.password) do|ssh|
      
      os = ssh.exec!("cat /etc/*release | tr -s '=' $'\t' |grep PRETTY_NAME |cut -f2")
      server.os = os
      if os.include?("CentOS")
        check_docker = ssh.exec!("yum list installed docker")
      elsif os.include?("Ubuntu")
        check_docker = ssh.exec!("dpkg-query -l docker.io")
      elsif os.include?("Debian")
        check_docker = ssh.exec!("dpkg-query -l docker.io")
      end

      docker_not_correctly_installed = check_docker.match(/docker/).nil?

      if docker_not_correctly_installed
        install_docker(server,ssh)
      end

      if !server.daemon_status
        run_docker_daemon(server, ssh)
      end
    end
  end

# This method uses the ssh connection and tries to install docker
#
# * *Args*    :
#   - +ssh+ -> needs a ssh connection
# * *Returns* :
#   - stdout -> returns the stdout from the ssh connection
# * *Raises* :
#   - Nothing 
  def self.install_docker(server, ssh)
    case
    when server.os.include?("CentOS")
      output = ssh.exec!("yum -y install docker")
    when server.os.include?("Ubuntu")
      output = ssh.exec!("apt-get install -y docker.io")
    when server.os.include?("Debian")
      output = ssh.exec!("apt-get install -y curl; curl -sSL https://get.docker.com/ | sh")
    end
  end

# This method uses the ssh connection and starts the docker daemon on port :5555
#
# * *Args*    :
#   - +server+ -> needs one server instance
#   - +ssh+ -> needs a ssh connection
# * *Returns* :
#   - Nothing 
# * *Raises* :
#   - Nothing 
  def self.run_docker_daemon(server, ssh)
    stop_docker_daemon(server, ssh)
    ssh.exec!("nohup docker -H tcp://#{server.host}:5555 -H unix:///var/run/docker.sock -d > foo.out 2> foo.err < /dev/null &")
  end

# This method uses the ssh connection and stops the daemon if it is running
#
# * *Args*    :
#   - +server+ -> needs one server instance
#   - +ssh+ -> needs a ssh connection
# * *Returns* :
#   - Nothing 
# * *Raises* :
#   - Nothing 
  def self.stop_docker_daemon(server, ssh)
    case
    when server.os.include?("CentOS")
      output = ssh.exec!("pkill -9 docker; rm /var/run/docker.pid")
    when server.os.include?("Ubuntu")
      output = ssh.exec("killall -9 docker; rm /var/run/docker.pid")
    when server.os.include?("Debian")
      output = ssh.exec!("apt-get install -y curl; curl -sSL https://get.docker.com/ | sh")
    end
    
  end
end