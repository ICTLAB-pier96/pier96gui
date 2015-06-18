class ImageBuildWorker
	require 'docker'
	include Common::DockerInteraction

    def perform(image_id, repo_credentials)
    	puts "starteddd"
    	prepare_docker
		image = Image.find(image_id)
		image.update_attribute(:status , 0)
		puts 0
		docker_prepare_status = authenticate_docker(repo_credentials['username'], repo_credentials['password'], repo_credentials['email'])
		if docker_prepare_status
			file_exists = Docker::Image.exist?(image.filename)
			dockerfile_dir = Rails.root.join('public', 'images')
			if !file_exists
				Dir.chdir(dockerfile_dir)
				puts 1
				docker_image = Docker::Image.build_from_tar(File.open(dockerfile_dir + image.filename, 'r'))
				puts 2
				docker_image.tag("repo" => image.repo + "/" + image.image, "force" => true)
				push_status = docker_image.push
				puts 3
				if push_status
					puts 5
					image.update_attribute(:status , 2)
				else
					puts 6
					image.update_attribute(:status , 1)
				end
			end
		else
			puts 4
			image.update_attribute(:status , 3)
		end
    end
end