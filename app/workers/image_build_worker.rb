# @author = Luuk
# ImageBuildWorker is a class, ment to be used as a Rails worker (background thread functionality).
# It only contains one method for performing.
class ImageBuildWorker
	require 'docker'
	include Common::DockerInteraction
	include Common::Debugging

	# This method builds a image from a tar file containing atleast a Dockerfile file optionally additional required files. Subsequently it pushes the image to the Docker Hub.
	# * *Args*    :
	#   - +image_id+ -> the ID of the image to build and push. [Integer]
	#   - +repo_credentials+ -> credentials of the Docker Hub for pushing the image to it. [Hashmap]
	# * *Returns* :
	#   - Nothing 
	# * *Raises* :
	#   - Nothing 
    def perform(image_id, repo_credentials)
    	prepare_docker
		image = Image.find(image_id)
		image.force_update_status(0)
		log("build started for image with id" + image_id, "info")

		docker_prepare_status = authenticate_docker(repo_credentials['username'], repo_credentials['password'], repo_credentials['email'])
		if docker_prepare_status
			file_exists = Docker::Image.exist?(image.filename)
			dockerfile_dir = Rails.root.join('public', 'images')
			if !file_exists
				Dir.chdir(dockerfile_dir)
				docker_image = Docker::Image.build_from_tar(File.open(dockerfile_dir + image.filename, 'r'))
				docker_image.tag("repo" => image.repo + "/" + image.image, "force" => true)
				push_status = docker_image.push
				if push_status
					image.force_update_status(2)
					log("build succeeded for image with id" + image_id, "info")
				else
					image.force_update_status(1)
					log("build failed for image with id" + image_id, "error")
				end
			end
		else
			image.force_update_status(3)
			log("authentication for build failed for image with id" + image_id, "error")
		end
    end
end