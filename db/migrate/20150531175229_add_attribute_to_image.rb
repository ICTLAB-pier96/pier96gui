class AddAttributeToImage < ActiveRecord::Migration
  def change
    add_column :images, :base_image, :string
  end
end
