class ImagesController < ApplicationController
  respond_to :html, :json
  require 'docker'

  # Begin methods for actions, these have to be the first methods in the controller class and need to be public
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

  public
    def new
      @image = Image.new
    end

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
      destroy_status = @image.destroy
      respond_to do |format|
        format.html
        format.json{
          render :json => destroy_status
        }
      end
      redirect_to action: :index
    end

  # End methods for actions

  private
    def define_image_parameters
      params.require(:image).permit(:repo, :image, :created)
    end



end

