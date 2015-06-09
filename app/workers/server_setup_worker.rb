class ServerSetupWorker
  def self.perform(id)
    server = Server.find(id)
    start_connection(server)
  end

  def self.start_connection(server)
    Net::SSH.start( server.host, server.user, :password => server.password) do|ssh|
        
      check_docker = ssh.exec!("dpkg-query -l docker.io")
      docker_not_correctly_installed = check_docker.match(/docker.io /).nil?

      if docker_not_correctly_installed
        install_docker(server.id,ssh)
      end

      if !server.daemon_status
        run_docker_daemon(server.id, ssh)
      end
    end
  end

  def self.install_docker(id, ssh)
    server = Server.find(id)
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

  def self.run_docker_daemon(server, ssh)
    ssh.exec("killall -9 docker; rm /var/run/docker.pid; nohup docker -H tcp://#{server.host}:5555 -H unix:///var/run/docker.sock -d > foo.out 2> foo.err < /dev/null &")
  end
end