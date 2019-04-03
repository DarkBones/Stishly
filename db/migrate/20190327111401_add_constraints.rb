class AddConstraints < ActiveRecord::Migration[5.2]
  def change
    change_column :accounts, :name, :string, null: false
    change_column :accounts, :currency, :string, null: false

    change_column :categories, :name, :string, null: false
    change_column :categories, :color, :string, null: false

    change_column :schedules, :name, :string, null: false
    change_column :schedules, :start_date, :date, null: false
    change_column :schedules, :period, :string, null: false
    change_column :schedules, :timezone, :string, null: false

    change_column :transactions, :timezone, :string, null: false
    #change_column :transactions, :local_datetime, :string, null: false

    change_column :schedules, :period_num, :integer, default: 0
    change_column :schedules, :days, :integer, default: 0
  end

end
