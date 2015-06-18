module Common
	module DockerInteraction
	  private
	    def authenticate_docker(repo_username, repo_password, repo_email)
	      begin
	        return Docker.authenticate!('username' => repo_username, 'password' => repo_password, 'email' => repo_email)
	      rescue
	        return false
	      end
	    end

	  private
	    def prepare_docker
	      Excon.defaults[:write_timeout] = 6000
	      Excon.defaults[:read_timeout] = 6000
	      host = '188.166.29.77';
	      Docker.url = "tcp://"+host+":5555/"
	    end
	end
end