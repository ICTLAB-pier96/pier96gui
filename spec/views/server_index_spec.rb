require "rails_helper"

describe "servers/index" do
  it "displays all the servers" do
    assign(:servers, [
      Server.create!(:name => "Hoi", :host => "129.45.46.123",:user => "user",:password => "pass"),
      Server.create!(:name => "Aap", :host => "129.45.46.123",:user => "user",:password => "pass"),
      Server.create!(:name => "Testx", :host => "129.45.46.123",:user => "user",:password => "pass"),
    ])

    render

    expect(rendered).to match /Hoi/
    expect(rendered).to match /Aap/
    expect(rendered).to match /Testx/
  end
end

describe "servers/show" do
  it "displays the show page" do
    assign(:server, 
      Server.create!(:id => 5, :name => "Hoi", :host => "129.45.46.123",:user => "user",:password => "pass"),
    )
    render

    expect(rendered).to match /Hoi/
  end
end

describe "servers/new" do
  it "shows the new server page" do
    render
    expect(rendered).to match /User/
    expect(rendered).to match /Host/
    expect(rendered).to match /Password/
    expect(rendered).to match /Name/
    expect(rendered).to match /Save/
  end
end

describe "servers/refresh" do
  it "shows the progress bar on the refresh page" do
    assign(:servers, [
      Server.create!(:name => "Hoi", :host => "129.45.46.123",:user => "user",:password => "pass"),
      Server.create!(:name => "Aap", :host => "129.45.46.123",:user => "user",:password => "pass"),
      Server.create!(:name => "Testx", :host => "129.45.46.123",:user => "user",:password => "pass"),
    ])
    render
   
    expect(rendered).to match /progress/
  end
end