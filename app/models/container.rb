class Container < ActiveRecord::Base
	belongs_to :server
    has_one :image
end
