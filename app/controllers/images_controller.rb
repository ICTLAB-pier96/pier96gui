# @author = Luuk Tersmette
# ImagesController extends the ApplicationController class, making it a Rails Controller. It acts as the controller in the Model View Controller setup.
# Extra methods are added for each action in the controller. These actions cover CRUD (create read update delete) and more.
# Used by: the rails framework.
class ImagesController < ApplicationController
  respond_to :html, :json
  require 'docker'
  include Common::DockerInteraction


  # << Begin methods for actions, these have to be the first methods in the controller class and need to be public

  # Listing all the images in either json or html format.
  # Used by: the rails framework
  # * *Args*    :
  #   - Nothing 
  # * *Returns* :
  #   - Nothing 
  # * *Raises* :
  #   - Nothing 
  public
    def index
      @images = Image.all
      respond_to do |format|
        format.html
        format.json{
          render :json => @images.to_json(:only => [ :id, :repo, :image, :created ])
        }
      end
    end

  # Showing one image based on a image ID get parameter.
  # Used by: the rails framework
  # * *Args*    :
  #   - Nothing 
  # * *Returns* :
  #   - Nothing 
  # * *Raises* :
  #   - Nothing 
  public
    def show
      @image = Image.find(params[:id])
      respond_to do |format|
        format.html
        format.json{
          render :json => @image.to_json(:only => [ :id, :repo, :image, :created, :status ])
        }
      end
    end

  # The action being called before the new image form.
  # Used by: the rails framework
  # * *Args*    :
  #   - Nothing 
  # * *Returns* :
  #   - Nothing 
  # * *Raises* :
  #   - Nothing 
  public
    def new
      @image = Image.new
    end

  # Creating a new image based on user entered parameters.
  # Depending on a form option, this either adds a reference to a existing image in the Docker Hub, or adds a reference to a newly created and added image.
  # Used by: the rails framework
  # * *Args*    :
  #   - Nothing 
  # * *Returns* :
  #   - Nothing 
  # * *Raises* :
  #   - Nothing 
  public
    def create
      @image = Image.new(define_image_parameters)

      typeselect = params[:image][:typeselect]
      repo = params[:image][:repo]
      image_name = params[:image][:image]


      if typeselect == "createexisting"
        result = @image.add_from_hub(repo, image_name)
      elsif typeselect == "createfromfile"
        upload_parameters = params[:image][:file]
        file_name = upload_parameters.original_filename
        repo_credentials = {"username" => params[:image][:repo_username], "password" => params[:image][:repo_password], "email" => params[:image][:repo_email]}
        result = @image.add_from_file(repo, repo_credentials, image_name, file_name, upload_parameters)
      else
        result = {"status" => false, "notice" => "Incorrect parameter for type select"}
      end
      if result["status"]
        redirect_to @image
      else
        if result["notice"] != ""
          flash.now[:notice] = "An error occurred:" + result["notice"]
        end
        render 'new'
      end
    end

  # @@Obsolete
  # This used to be used to update fuction used to update a image in the database.
  # However, Images are longer just database entries after a major overhaul in the application. This method therefore doesnt fully suffice updating a Image.
  # It is still there for when update functionality will return in the future.
  # Used by: the rails framework
  # * *Args*    :
  #   - Nothing 
  # * *Returns* :
  #   - Nothing 
  # * *Raises* :
  #   - Nothing 
  public
    def update
      @image = Image.find(params[:id])
   
      if @image.update(define_image_parameters)
        redirect_to @image
      else
        render 'edit'
      end
    end
 
  # This destroys the image.
  # Used by: the rails framework
  # * *Args*    :
  #   - Nothing 
  # * *Returns* :
  #   - Nothing 
  # * *Raises* :
  #   - Nothing 
  public
    def destroy
      @image = Image.find(params[:id])
      destroy_status = @image.destroy
      respond_to do |format|
        format.html{
          redirect_to action: :index
        }
        format.json{
          render :json => destroy_status
        }
      end
      
    end

  # End methods for actions />


  # Filters image parameters to only allow specific ones. This is for security, since not all parameters should be alterable from passing GET variables.
  # Used by: the rails framework
  # * *Args*    :
  #   - Nothing 
  # * *Returns* :
  #   - Nothing 
  # * *Raises* :
  #   - Nothing 
  private
    def define_image_parameters
      params.require(:image).permit(:repo, :image, :created)
    end



end

