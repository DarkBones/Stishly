class Resetemail < ActiveRecord::Migration[5.2]
  def change
  	rename_column :users, :email_enc, :email
  	change_column :users, :email, :string
  end
end
