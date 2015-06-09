class CustomIdContainer < ActiveRecord::Migration
  def change
  	  	drop_table(:containers, if_exists: true)
  	  	
  	  	create_table :containers, id: :string do |t|
  		  	t.string :args
  		  	t.string :command
  		  	t.date :created
  		  	t.text :description
  		  	t.string :image
  		  	t.string :labels
  		  	t.string :name
  		  	t.string :local_port
  		  	t.string :host_port
  		  	t.string :state
  		  	t.integer :server_id
  		  	t.string :ports

  	  		t.timestamps null: false
  	  	end
  end
end
