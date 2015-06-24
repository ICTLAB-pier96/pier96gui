#  @author = Patrick
class SettingsController < ApplicationController
  respond_to :html, :json

  def index
    get_variables
    render "index"
  end

  def update
    get_variables

    @progress_id = ProgressBar.create.id
    NginxService::Config.update(@progress_id)
    flash[:notice] = 'Nginx containers are currently being updated.'
    render "index"
  end

  private

  def get_variables
    @settings = Settings.new
    @config_file = @settings.formatted_config_file
    @servers_nginx_containers = @settings.servers_nginx_containers
    @servers_gui_containers = @settings.servers_gui_containers
  end
end
