class ServerSetupWorker
  def self.perform
    server = Server.find(1)
    start_connection(server)
  end

  def start_connection(server)
    Net::SSH.start( server.host, server.user, :password => server.password) do|ssh|
      if server.daemon
    end
  end

  def install_docker(server, ssh)
    if server.os.include? "Ubuntu"
      output = ssh.exec!("apt-get install -y docker.io")
    elsif server.os.include? "Debian"
      output = ssh.exec!("apt-get install -y docker.io")
    elsif server.os.include? "CentOS-6.5"
      output = ssh.exec!("yum -y install docker-io")
    elsif server.os.include? "CentOS-7.0"
      output = ssh.exec!("yum -y install docker-io")
    elsif server.os.include? "Fedora 20"
      output = ssh.exec!("yum -y remove docker; yum -y install docker-io")
    elsif server.os.include? "Fedora"
      output = ssh.exec!("yum -y install docker")
    end
    puts outpu
  end

  def run_docker_daemon(server, ssh)
    ssh.exec("killall -9 docker; rm /var/run/docker.pid")
  end
end