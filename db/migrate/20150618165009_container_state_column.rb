class ContainerStateColumn < ActiveRecord::Migration
  def change
  	change_column(:containers, :state, :text)
  end
end
