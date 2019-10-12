class LocalDate < ActiveRecord::Migration[5.2]
  def change
  	add_column :daily_budgets, :local_date, :date
  end
end
