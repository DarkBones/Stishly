class AddFreeTrialEligable < ActiveRecord::Migration[5.2]
  def change
  	add_column :users, :free_trial_eligable, :boolean, default: true
  end
end
