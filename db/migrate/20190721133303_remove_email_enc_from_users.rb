class RemoveEmailEncFromUsers < ActiveRecord::Migration[5.2]
  def change
  	remove_column :users, :email_enc
  end
end
