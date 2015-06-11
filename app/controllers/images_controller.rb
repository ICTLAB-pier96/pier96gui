class ImagesController < ApplicationController
  require 'docker'

  # Begin methods for actions, these have to be the first methods in the controller class and need to be public
  public
    def index
      @images = Image.all
    end

  public
    def show
      @image = Image.find(params[:id])
    end

  public
    def new
      @image = Image.new
    end

  public
    def edit
      @image = Image.find(params[:id])
    end

  public
    def create
      @image = Image.new(define_image_parameters)
      
      

      if @image.save
        if params[:image][:file]
          upload_parameters = params[:image][:file]
          repo = params[:image][:repo]
          image_name = params[:image][:image]
          file_name = upload_parameters.original_filename
          repo_username = params[:image][:repo_username]
          repo_password = params[:image][:repo_password]
          repo_email = params[:image][:repo_email]

          @image.filename = file_name
          authenticate_status = prepare_docker(repo_username, repo_password, repo_email)
          if authenticate_status
            puts "authentication success"
            File.open(Rails.root.join('public', 'images', file_name), 'wb') do |file|
              file.write(upload_parameters.read)
            end
            build_image_from_file(repo, image_name, file_name)
          else
            puts "authentication failed"
          end
        end
        redirect_to @image
      else
        render 'new'
      end
    end

  public
    def createexisting
      @image = Image.find(params[:id])
    end

  public
    def update
      @image = Image.find(params[:id])
   
      if @image.update(define_image_parameters)
        redirect_to @image
      else
        render 'edit'
      end
    end
 
  public
    def destroy
      @image = Image.find(params[:id])
      @image.destroy
   
      redirect_to action: :index
    end

  # End methods for actions

  private
    def define_image_parameters
      params.require(:image).permit(:repo, :image, :created)
    end

  private
    def build_image_from_file(repo, image_name, file_name)
      image_exists = Docker::Image.exist?(file_name)
      dockerfile_dir = Rails.root.join('public', 'images')
      contents = File.open(dockerfile_dir + file_name, 'rb') { |file| file.read }
      if !image_exists
        Dir.chdir(dockerfile_dir)
        image = Docker::Image.build(contents)
        image.tag("repo" => repo + "/" + image_name, "force" => true)
        image.push
      end
    end

  private
    def prepare_docker(repo_username, repo_password, repo_email)
      Excon.defaults[:write_timeout] = 6000
      Excon.defaults[:read_timeout] = 6000

      docker_file_directory = Rails.root.join('public', 'images')
      host = '188.166.29.77';
      Docker.url = "tcp://"+host+":5555/"
      puts repo_username
      puts repo_password
      puts repo_email
      begin
        return Docker.authenticate!('username' => repo_username, 'password' => repo_password, 'email' => repo_email)
      rescue
        return false
      end
    end
end

