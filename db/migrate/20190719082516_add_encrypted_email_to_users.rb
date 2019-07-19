class AddEncryptedEmailToUsers < ActiveRecord::Migration[5.2]
  def change
  	add_column :users, :encrypted_email, :string
  	add_column :users, :encrypted_email_iv, :string
  	add_index :users, :encrypted_email_iv, unique: true

  	add_column :users, :encrypted_email_bidx, :string
  	add_index :users, :encrypted_email_bidx, unique: true

  	remove_column :users, :email
  end
end
