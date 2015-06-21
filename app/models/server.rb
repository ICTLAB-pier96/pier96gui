class Server < ActiveRecord::Base
  ip_regex = /^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$/
  url_regex = URI.regexp
  validates :host, :format => { :with => ip_regex, :multiline => true , :message => "This is not a valid host" }, :presence => { :message => " can't be blank" }
  validates :name, :presence => { :message => " can't be blank" }
  validates :user, :presence => { :message => " can't be blank" }
  validates :password, :presence => { :message => " can't be blank" }

  def get_server_status
    Net::SSH.start( self.host, self.user, :password => self.password, :timeout => 5) do|ssh|
      status = ssh.exec!("echo true")
      ram_usage = ssh.exec!("free | grep Mem | awk '{print $3/($2+$7)*100.0}'")
      disk_space = ssh.exec!("df | tr -s ' ' $'\t' | grep /dev/ | cut -f4")
      
      server_load = ServerLoad.new(:server_id => self.id, :ram_usage => ram_usage.to_i).save
      helper = Object.new.extend(ActionView::Helpers::NumberHelper) 
      self.update_attributes(
        :ram_usage => ram_usage.to_i.round,
        :disk_space => helper.number_to_human_size((disk_space.to_i*1024)),
        :status => (status === "true\n")
        )
    end
  end

  def get_daemon_status
    url = URI.parse("http://"+ self.host.gsub("http://","")+":5555/info")
    http = Net::HTTP.new(url.host, url.port)
    http.read_timeout = 5
    http.open_timeout = 5
    http.start do |connection|
      url = URI.parse(URI.encode("http://" + self.host.gsub("http://","")+":5555/info"))
      request = Net::HTTP::Get.new(url.request_uri)
      @response = connection.request(request)
      status =  JSON.parse(@response.body, :symbolize_names => true)
      helper = Object.new.extend(ActionView::Helpers::NumberHelper) 
      self.update_attributes(
        :status => true,
        :daemon_status => true,
        :storage => helper.number_to_human_size(status[:MemTotal]),
        :ram_usage => status[:ram_usage],
        :os => status[:OperatingSystem], 
        :total_containers => status[:Containers],
        :total_images => status[:Images]
        )
    end
  end

  # This method creates a ssh connection and checks if it has docker installed and the daemon is running correctly
  #
  # * *Args*    :
  #   - +server+ -> needs one server instance
  # * *Returns* :
  #   - Nothing 
  # * *Raises* :
  #   - Nothing 
  def start_setup
    Net::SSH.start( self.host, self.user, :password => self.password) do|ssh|

      os = ssh.exec!("cat /etc/*release | tr -s '=' $'\t' |grep PRETTY_NAME |cut -f2")

      cmd = case os
      when /CentOS/
        "yum list installed docker"
      when /Ubuntu/
        "dpkg-query -l docker.io"
      when /Debian/
        "dpkg-query -l docker.io"
      end
      check_docker = ssh.exec!(cmd)
      self.os = os

      install_docker(ssh) if check_docker.match(/docker/).nil?
      run_docker_daemon(ssh) unless self.daemon_status
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
  def install_docker(ssh)
    cmd = case self.os
    when /CentOS/
      "yum -y install docker"
    when /Ubuntu/
      "apt-get install -y docker.io"
    when /Debian/
      "apt-get install -y curl; curl -sSL https://get.docker.com/ | sh"
    end
    ssh.exec!(cmd)
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
  def run_docker_daemon(ssh)
    stop_docker_daemon(ssh)
    output = ssh.exec!("nohup docker -H tcp://#{self.host}:5555 -H unix:///var/run/docker.sock -d > foo.out 2> foo.err < /dev/null &")
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
  def stop_docker_daemon(ssh)
    cmd = case self.os
    when /CentOS/
      "pkill -9 docker; rm /var/run/docker.pid"
    when /Ubuntu/
      "killall -9 docker; rm /var/run/docker.pid"
    when /Debian/
      "apt-get install -y curl; curl -sSL https://get.docker.com/ | sh"
    end
    ssh.exec!(cmd)
  end
end
