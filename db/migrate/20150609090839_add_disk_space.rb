class AddDiskSpace < ActiveRecord::Migration
  def change
       add_column :servers, :disk_space, :string
  end
end
