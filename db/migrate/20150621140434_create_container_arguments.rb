class CreateContainerArguments < ActiveRecord::Migration
  def change
    create_table :container_arguments do |t|
    	t.string :name
    	t.string :value
      t.timestamps null: false
    end
  end
end
