class RemoveNullConstraint < ActiveRecord::Migration[5.2]
  def change
    change_column :transactions, :user_currency_amount, :integer, :null => true
  end
end
