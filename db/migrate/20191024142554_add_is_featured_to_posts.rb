class AddIsFeaturedToPosts < ActiveRecord::Migration[5.2]
  def change
    add_column :posts, :is_featured, :boolean
    add_column :posts, :description, :string
  end
end
