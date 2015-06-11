class Server < ActiveRecord::Base
    url_regex = /^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$/
    validates :host, :format => { :with => url_regex, :multiline => true , :message => "This is not a valid host" }, presence: { message: " can't be blank" }
    validates :user, presence: { message: " can't be blank" }
    validates :password, presence: { message: " can't be blank" }
end
