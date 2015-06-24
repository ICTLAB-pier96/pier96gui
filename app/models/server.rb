# @author = Patrick
#
class Server < ActiveRecord::Base
  # constants
  IP_REGEX = /^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$/
  URL_REGEX = URI.regexp

  # assocation
  has_many :server_load

  # validations
  validates :host, :format => { :with => IP_REGEX, :multiline => true , :message => " is not a valid url or ip" }, :presence => { :message => " can't be blank" }
  validates :name, :presence => { :message => " can't be blank" }
  validates :user, :presence => { :message => " can't be blank" }
  validates :password, :presence => { :message => " can't be blank" }

  # This method updates the status of a server
  # If the server is online it will grab some server details: ram_usage, disk_space
  #
  # * *Args*    :
  #   - Nothing 
  # * *Returns* :
  #   - Nothing
  # * *Raises* :
  #   - Exceptions -> exceptions will be caught higher, when this method is called
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
    http.read_timeout = http.open_timeout = 5
    
    http.start do |connection|
      url = URI.parse(URI.encode("http://" + self.host.gsub("http://","")+":5555/info"))
      request = Net::HTTP::Get.new(url.request_uri)
      response = connection.request(request)
      status =  JSON.parse(response.body, :symbolize_names => true)
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
    else 
      "apt-get install -y curl; curl -sSL https://get.docker.com/ | sh"
    end
    ssh.exec!(cmd)
  end

  # This method uses the ssh connection and starts the docker daemon in the background on port :5555
  #
  # * *Args*    :
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
  # It calls the kil
  # * *Args*    :
  #   - +ssh+ -> needs a ssh connection
  # * *Returns* :
  #   - Nothing 
  # * *Raises* :
  #   - Nothing 
  def stop_docker_daemon(ssh)
    cmd = case self.os
    when /CentOS/
      "pkill docker; rm /var/run/docker.pid"
    when /Ubuntu/, /Debian/
      "killall docker; rm /var/run/docker.pid"
    end
    ssh.exec!(cmd)
  end
end
