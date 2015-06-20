class Server < ActiveRecord::Base
    ip_regex = /^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$/
    url_regex = URI.regexp
    validates :host, :format => { :with => ip_regex, :multiline => true , :message => "This is not a valid host" }, presence: { message: " can't be blank" }
    validates :name, presence: { message: " can't be blank" }
    validates :user, presence: { message: " can't be blank" }
    validates :password, presence: { message: " can't be blank" }
end
