class MergeMigrations < ActiveRecord::Migration[5.2]

  def change
  
    create_table :account_histories do |t|
      t.references :account
      t.datetime :local_datetime
      t.integer :balance
      t.timestamps
    end
    
    create_table :accounts do |t|
      t.integer :balance, default: 0
      t.references :currency # TODO: remove or transform into foreign key
      t.references :user
      t.string :name
      t.string :description
      t.integer :position
      t.string :currency
      t.boolean :is_default # TODO: remove field
      t.timestamps
      t.index :name
    end
    
    create_table :apis do |t|
      t.timestamps
    end
    
    create_table :categories do |t|
      t.string :name
      t.string :color
      t.string :symbol
      t.references :user
      t.references :parent
      t.timestamps
    end
    
    create_table :countries do |t|
      t.string :name
      t.string :date_format
      t.integer :week_start
      t.string :country_code
      t.timestamps
    end
    
    create_table :currencies do |t| # TODO: remove table
      t.string :name
      t.string :symbol
      t.string :iso_code
      t.integer :number_to_basic
      t.timestamps
    end
    
    create_table :currency_rates do |t|
      t.string :from_currency
      t.string :to_currency
      t.float :rate
      t.integer :used_count
      t.timestamps
    end
    
    create_table :schedules do |t|
      t.string :name
      t.references :user
      t.date :start_date
      t.date :end_date
      t.string :period
      t.integer :period_num, default: 0
      t.integer :days, default: 0
      t.string :days_month
      t.integer :days_month_day
      t.integer :days_exclude
      t.string :exclusion_met
      t.integer :exclusion_met_day
      t.string :timezone
      t.boolean :is_active, default: true
      t.date :next_occurrence
      t.date :last_occurrence
      t.datetime :next_occurrence_utc
      t.timestamps
      t.index :name
    end
    
    create_table :schedules_transactions do |t|
      t.references :schedule
      t.references :transaction
    end
    
    create_table :setting_values do |t|
      t.references :entity
      t.references :setting
      t.string :value
      t.string :entity_type
      t.timestamps
    end
    
    create_table :settings do |t|
      t.string :description
      t.timestamps
    end
    
    create_table :subscription_tiers do |t|
      t.string :name
      t.integer :cost
      t.integer :month_billing_cycle
      t.timestamps
    end
    
    create_table :transactions do |t|
      t.references :user
      t.integer :amount
      t.integer :direction
      t.string :description
      t.references :account
      t.string :timezone
      t.string :currency
      t.integer :account_currency_amount
      t.references :category
      t.references :parent
      t.datetime :local_datetime
      t.references :transfer_account
      t.integer :user_currency_amount
      t.references :transfer_transaction
      t.references :scheduled_transaction
      t.boolean :is_scheduled
      t.timestamps
    end
    
    create_table :users do |t|
      t.string :first_name
      t.string :last_name
      t.references :subscription_tier, default: 1
      t.string :email, default: "", null: false
      t.string :encrypted_password, default: "", null: false
      t.string :reset_password_token
      t.datetime :reset_password_sent_at
      t.datetime :remember_created_at
      t.integer :sign_in_count, default: 0, null: false
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string :current_sign_in_ip
      t.string :last_sign_in_ip
      t.string :confirmation_token
      t.datetime :confirmed_at
      t.datetime :confirmation_sent_at
      t.string :unconfirmed_email
      t.integer :failed_attempts, default: 0, null: false
      t.string :unlock_token
      t.datetime :locked_at
      t.string :timezone
      t.string :country_code
      t.references :country
      t.string :currency, null: false
      t.timestamps
      t.index :confirmation_token
      t.index :email
      t.index :reset_password_token
      t.index :unlock_token
    end
  
  end

end
