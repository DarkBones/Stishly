class UsersBinary < ActiveRecord::Migration[5.2]
  def change
  	change_column :users, :first_name_enc, :binary
  	change_column :users, :last_name_enc, :binary
  	change_column :users, :email_enc, :binary
  end
end
