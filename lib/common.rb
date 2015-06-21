# @author = Luuk
# A library module for common functionality for larger parts of the application.
module Common

	# @author = Luuk
	# A submodule that encapsulates all functionality for interacting with the Docker API via the Docker API gem.
	module DockerInteraction

		# Authenticate to the Docker Hub and return a status.
		# * *Args*    :
		#   - +repo_username+ -> the username for Docker Hub. [String]
		#   - +repo_password+ -> the username for Docker Hub. [String]
		#   - +repo_email+ -> the email for Docker Hub. [String]
		# * *Returns* :
		#   - return status [Boolean] 
		# * *Raises* :
		#   - Nothing 
		public
			def authenticate_docker(repo_username, repo_password, repo_email)
			  begin
			    return Docker.authenticate!('username' => repo_username, 'password' => repo_password, 'email' => repo_email)
			  rescue
			    return false
			  end
			end

		# prepare for interacting with Docker.
		# Make the timeout for writing to a socket 6000 seconds, and also set the correct url for interacting with the Docker API.
		# * *Args*    :
		#   - Nothing 
		# * *Returns* :
		#   - Nothing 
		# * *Raises* :
		#   - Nothing 
		public
		    def prepare_docker
		      Excon.defaults[:write_timeout] = 6000
		      Excon.defaults[:read_timeout] = 6000
		      host = '188.166.29.77';
		      Docker.url = "tcp://"+host+":5555/"
		    end
	end

	# @author = Luuk
	# A submodule that encapsulates all functionality for debugging the application.
	module Debugging
		public
			# A method for making a log entry for either displaying information or showing a error.
			# The log entries are set to be written to a log file, then sanitized for security purposes and finally a log entry is made.
			# * *Args*    :
			#   - +message+ -> the log entry message [String]
			#   - +level+ -> the log level [String]
			# * *Returns* :
			#   - Nothing 
			# * *Raises* :
			#   - Nothing 
			def log(message, level)
				logger = Logger.new("#{Rails.root}/log/debug.log")
				original_formatter = Logger::Formatter.new
				logger.formatter = proc { |severity, datetime, progname, msg|
					original_formatter.call(severity, datetime, progname, msg.dump)
				}
				case level
				when 'info'
					logger.info(message)
				when 'error'
					logger.error(message)
				else
					logger.error("invalid log level")
			end

	end
end
end