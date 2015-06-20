require 'rails_helper'


RSpec.describe Server do
  it "passes all validations when filled in correctly" do
    server = Server.new(name: "serverx", user: "root", password: "Pier96", host: "188.124.63.34")
    expect(server.valid?).to be true   
  end
  it "fails when server is missing name" do
    server = Server.new(user: "root", password: "Pier96", host: "188.124.63.34")
    expect(server.valid?).to be false   
  end
    it "fails when server is missing host" do
    server = Server.new(name: "serverx", user: "root", password: "Pier96")
    expect(server.valid?).to be false   
  end
    it "fails when server is missing user" do
    server = Server.new(name: "serverx", password: "Pier96", host: "188.124.63.34")
    expect(server.valid?).to be false   
  end
    it "fails when server is missing password" do
    server = Server.new(name: "serverx", user: "root", host: "188.124.63.34")
    expect(server.valid?).to be false   
  end
end
