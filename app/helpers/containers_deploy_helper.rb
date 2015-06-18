module ContainersDeployHelper
    require 'docker'

    def self.deploy(container)
        dir = Image.find(container.image_id).title
        host = Server.find(container.server_id).host
        localport = container.local_port
        hostport = container.host_port

        ContainersDeployHelper.run(
            {:dir => Rails.root.join('public', 'images', dir), 
            :image => "#{dir}",
            :host => host,
            :c_args => {"ExposedPorts" => { "#{localport}/tcp" => {} }, 
                        "PortBindings" => { "#{localport}/tcp" => [{ "HostPort" => "#{hostport}" }] }}})
    end

    def self.run(args)
        begin
            host = args.fetch(:host)
            name = args.fetch(:git_clone,{:name => nil}).fetch(:name)
            repo = args.fetch(:git_clone,{:repo => nil}).fetch(:repo)
            image_name = args.fetch(:image)
            customargs = args.fetch(:c_args)
            dockerfile_dir = args.fetch(:dir)

            Docker.url = "tcp://"+host+":5555/"

            Excon.defaults[:write_timeout] = 6000
            Excon.defaults[:read_timeout] = 6000

            Dir.chdir(dockerfile_dir)
            if !repo.nil?
                system "git clone "+repo+" "+name+""
                system "cp Dockerfile "+name+"/Dockerfile"
            end

            # Build image from dockerfile
            image = Docker::Image.exist?(image_name)
            if !image
                image = Docker::Image.build_from_dir(""+name+"/.")
                image.tag("repo" => image_name, "force" => true)
            end
            customargs["Image"] = image_name
            container = Docker::Container.create(customargs)
            container.start
            container
        rescue => error
            puts error.message
        end
    end

    def deploy(args)
        return ContainersDeployHelper.deploy(args)
    end
end