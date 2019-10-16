class CreatePosts < ActiveRecord::Migration[5.2]
  def change
    create_table :posts do |t|
      t.string :title
      t.text :body
      t.string :thumbnail
      t.date :published_on
      t.string :hash_id

      t.timestamps
    end
  end
end
