class CreateImages < ActiveRecord::Migration
  def change
    create_table :images do |t|
      t.string :title
      t.string :date_added
      t.string :base_image
      t.string :filename
      t.timestamps null: false
    end
  end
end
