class CreateServers < ActiveRecord::Migration
  def change
    create_table :servers do |t|
      t.string :name
      t.string :host
      t.string :user
      t.string :pass
      t.boolean :status
      t.string :os
      t.string :storage
      t.string :total_containers
      t.string :total_images

      t.timestamps null: false
    end
  end
end
