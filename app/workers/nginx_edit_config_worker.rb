# @author = Patrick
# NginxEditConfigWorker is a process that should run in the background, it is used to update the applications nginx balancer
class NginxEditConfigWorker

  def self.perform(server, container_id, config_file)
    create_config_file(config_file)
    push_config_file(server, container_id)
    reload_nginx(server, container_id)
  end

  def self.create_config_file(config_file)
    File.open(Rails.root.join('tmp', 'config'), 'wb') do |file|
        file.write(config_file)
    end
  end


  def self.push_config_file(server, container_id)
    require 'net/scp'
    Net::SCP.start(server.host, server.user, :password => server.password ) do |scp|
      scp.upload(Rails.root.join('tmp', 'config').to_s,"config")
    end
    Net::SSH.start( server.host, server.user, :password => server.password) do|ssh|
      ssh.exec!("cp config /var/lib/docker/aufs/mnt/#{container_id}/etc/nginx/sites-enabled/config")
      ssh.exec!("rm config")
    end
  end

  def self.reload_nginx(server, container_id)
    Net::SSH.start( server.host, server.user, :password => server.password) do|ssh|
        ssh.exec!("docker exec #{container_id} service nginx reload")
    end
  end
end
