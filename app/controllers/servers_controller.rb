#  @author = Patrick
class ServersController < ApplicationController
  def new
  end

  def create
    @server = Server.new(server_params)
    if @server.valid?
      @server.save
      redirect_to @server
    else
      flash[:error] = @server.errors.full_messages.to_sentence
      redirect_to :back
    end
  end

  def index
    @servers = Server.all
    @time = Time.now.utc
    respond_to do |format|
      format.html
      format.json{
        image = params.fetch(:image,nil)
        unless image.nil?
          server_ids = Container.all.where(image: image).map(&:server_id)
          @servers = Server.find(server_ids)
        end
        render json: @servers.to_json(only: [:id, :name, :host])
      }
    end
  end
  
  def destroy
    @server = Server.find(params.fetch(:id))
    @server.destroy

    redirect_to action: :index
  end

  def refresh
    @progress_id = ProgressBar.create.id
    ServerService::Status.update_status_for_all_servers(@progress_id)
    flash[:notice] = "Servers' status is currently being checked, this could take a while."
    @servers = Server.all
    render "index"
  end

  def setup
    @server = Server.find(params.fetch(:id))
    @progress_id = ProgressBar.create.id

    ServerService::Setup.setup_server(@server.id, @progress_id)
    flash[:notice] = 'Setup is running, this could take a while.'
    render "show"
  end

  def show
    @server = Server.find(params.fetch(:id))
    respond_to do |format|
      format.html
      format.json{
        render json: @server.to_json(only: [:id, :name, :host])
      }
    end
  end

  private
  
  def server_params
    params.require(:server).permit(:name, :host, :user, :password)
  end
end
