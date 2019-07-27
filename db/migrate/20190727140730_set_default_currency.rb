class SetDefaultCurrency < ActiveRecord::Migration[5.2]
  def change
  	change_column :users, :currency, :string, :default => "USD"
  end
end
