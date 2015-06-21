class Image < ActiveRecord::Base
	include Common::DockerInteraction

	def add_from_hub(repo, image_name)
		self.status = -2

        if repo != ""
          if repo.length < 2
            return {"status" => false, "notice" => "Repository length must be no fewer then 2 characters in length if entered."}
          else
            search_term = repo + '/' + image_name
          end
        else
          search_term = image_name
        end
        search_results = Docker::Image.search('term' => search_term)
        match_found = false
        search_results.each do |search_result|
          if search_result.id == search_term
            match_found = true
            break
          end
        end
        if match_found
          if self.save
          	return {"status" => true, "notice" => ""}
          else
            return {"status" => false, "notice" => ""}
          end
        else
        	return {"status" => false, "notice" => "Repository length must be no fewer then 2 characters in length if entered."}
        end
	end

	def add_from_file(repo, repo_credentials, image_name, file_name, upload_parameters)
		prepare_docker

		self.filename = file_name
		self.status = -1

        if self.save
          image_id = self.id
          authenticate_status = authenticate_docker(repo_credentials['username'], repo_credentials['password'], repo_credentials['email'])
          file_status = false
          if authenticate_status
            File.open(Rails.root.join('public', 'images', file_name), 'wb') do |file|
              file_status = file.write(upload_parameters.read)
              puts file_status
            end
            if file_status != false
              image_build_worker = ImageBuildWorker.new
              image_build_worker.delay.perform(image_id, repo_credentials)
              return {"status" => true, "notice" => ""}
            else
              return {"status" => false, "notice" => "Failed to save docker file to server"}
            end
          else
            return {"status" => false, "notice" => "Authentication to docker hub failed"}
          end
        else
          return {"status" => false, "notice" => ""}
        end
    end
end
