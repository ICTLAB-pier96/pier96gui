class ContainerArgument < ActiveRecord::Base
	belongs_to :container
	attr_accessor :name, :value
end
