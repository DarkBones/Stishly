class NoTrial < ActiveRecord::Migration[5.2]
  def change
  	add_column :stripe_plans, :plan_id_month_no_trial, :string
  	add_column :stripe_plans, :plan_id_year_no_trial, :string
  end
end
