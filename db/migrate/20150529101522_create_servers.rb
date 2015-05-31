class CreateServers < ActiveRecord::Migration
  def change
    create_table :servers do |t|
      t.string :name
      t.string :host
      t.string :user
      t.string :pass
      t.boolean :status
      t.boolean :setup
      t.string :setup_info

      t.timestamps null: false
    end
  end
end
