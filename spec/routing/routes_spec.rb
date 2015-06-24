require "rails_helper"

RSpec.describe "routes to the settings controller", :type => :routing do
  it "routes a named route" do
    expect(:get => settings_path).
      to route_to(:controller => "settings", :action => "index")
    expect(:get => "/settings/nginx_update").
      to route_to(:controller => "settings", :action => "update")
  end
end

RSpec.describe "routes to the servers controller", :type => :routing do
  it "routes a named route" do
    expect(:get => new_server_path).
      to route_to(:controller => "servers", :action => "new")
  end
  it "routes other routes" do
    expect(:get => "/servers").
      to route_to(:controller => "servers", :action => "index")
    expect(:get => "/servers/refresh").
      to route_to(:controller => "servers", :action => "refresh")
    expect(:get => "/servers/1").
      to route_to(:controller => "servers", :action => "show", :id => "1")
  end
end