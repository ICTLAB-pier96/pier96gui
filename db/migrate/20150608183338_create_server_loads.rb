class CreateServerLoads < ActiveRecord::Migration
  def change
    create_table :server_loads do |t|
      t.integer :server_id
      t.integer :ram_usage
      t.timestamps null: false
    end
  end
end
