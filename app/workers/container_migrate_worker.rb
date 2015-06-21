# @author = Patrick
class ContainerMigrateWorker
  def initialize(server_id, container_id)
    @server = Server.find(server_id)
    @container = Container.find(container_id)
  end


  def migrate_container_to_server
    Net::SSH.start(@server.host, @server.user, :password => @server.password) do|ssh|
      export_tar_to_server(ssh)
      import_from_tar(ssh)
      start_container(ssh)
      remove_tar(ssh)
    end
  end

  def export_tar_to_server(ssh)
    container_ip = Server.find(@container.server_id).host
    output = ssh.exec!("curl http://#{container_ip}:5555/containers/#{@container.id}/export > export.tar")
    puts output
  end

  def import_from_tar(ssh)
    output = ssh.exec!("cat export.tar | docker import - #{@container.image}:tmp")
  end

  def start_container(ssh)
    output = ssh.exec!("docker run -d -p #{@container.local_port}:#{@container.host_port} #{@container.image}:tmp #{@container.command}")
    puts output
  end

  def remove_tar(ssh)
    output = ssh.exec!("rm export.tar")
  end
end
