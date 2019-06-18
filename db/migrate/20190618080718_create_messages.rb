class CreateMessages < ActiveRecord::Migration[5.2]
  def change
    create_table :messages do |t|
      t.references :user
      t.string :title
      t.text :body
      t.boolean :read, :default => false
      t.timestamp :read_at
      t.string :link
      t.timestamps
    end
  end
end
