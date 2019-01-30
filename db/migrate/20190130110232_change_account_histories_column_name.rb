class ChangeAccountHistoriesColumnName < ActiveRecord::Migration[5.2]
  def change
    rename_column :account_histories, :account_id_id, :account_id
  end
end
