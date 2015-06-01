class CreateContainers < ActiveRecord::Migration
  def change
    create_table :containers do |t|
      t.string :name
      t.integer :server_id
      t.string :ports
      t.text :description
      t.integer :image_id
      t.integer :host_port
      t.integer :local_port

      t.timestamps null: false
    end
  end
end
