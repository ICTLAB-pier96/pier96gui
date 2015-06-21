#  @author = Patrick
class SettingsController < ApplicationController
  respond_to :html, :json
  include ActionView::Helpers::TextHelper

  def index
    @settings = Settings.new
    @config_file = @settings.formatted_config_file
    @servers_nginx_containers = @settings.servers_nginx_containers
    @servers_gui_containers = @settings.servers_gui_containers
  end

  def update
    @settings = Settings.new
    @settings.update
    flash[:notice] = 'Nginx containers are currently being updated.'
    redirect_to action: :index
  end
end
