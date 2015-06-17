require 'rails_helper'

RSpec.describe Server, type: :model do
  it "is valid with a host, user and password" do
    server = Server.new(
        host: '0.0.0.0',
        user: 'root',
        password: 'password')
    expect(server).to be_valid
  end

  it "is not valid without host" do
    server = Server.new(
        user: 'root',
        password: 'password',
        host: 'localhost')

    expect(server.errors[:host]).to include("This is not a valid host")
  end
  it "is not valid without user" do
    server = Server.new(
        host: '0.0.0.0',
        password: 'password')
    expect(server.errors[:user]).to include("can't be blank")
  end
  it "is not valid without password" do
    server = Server.new(
        user: 'root',
        host: '0.0.0.0')
    expect(server.errors[:password]).to include("can't be blank")
  end
end
