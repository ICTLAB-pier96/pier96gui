# @author = Patrick
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
    server.start_setup
  end
end