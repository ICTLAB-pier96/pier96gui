class AddRamUsage < ActiveRecord::Migration
  def change
     add_column :servers, :ram_usage, :string
  end
end
