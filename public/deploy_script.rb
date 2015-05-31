    #!/usr/bin/ruby
def deploy(args)
    puts args
    host = args.fetch(:host)
    name = args.fetch(:git_clone,{:name => nil}).fetch(:name)
    repo = args.fetch(:git_clone,{:repo => nil}).fetch(:repo)
    image_name = args.fetch(:image)
    customargs = args.fetch(:c_args)
    dockerfile_dir = args.fetch(:dir)

    require 'docker'

    # exec './prepare'
    Docker.url = "tcp://"+host+":5555/"

    # images = Docker::Image.all

    # images.each do |image|
    #     image.remove(:force => true)
    # end
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
end


