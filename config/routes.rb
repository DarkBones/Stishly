Rails.application.routes.draw do

  resources :accounts do
    collection do
      patch :sort
    end
  end

  resource :transactions, only: [:show]
  resource :user_settings, only: [:edit]
  resource :schedules_transactions
  #resource :schedules, only: [:index]

  get 'accounts/:id/settings', to: 'accounts#settings', as: :account_settings

  post 'settings/edit', to: 'users#edit', as: :edit_settings
  get 'settings', to: 'users#settings'
  post 'accounts/:id/settings/edit', to: 'accounts#edit', as: :edit_account_settings
  get 'accounts/:id/set_default', to: 'accounts#set_default', as: :set_default_account

  get 'schedules', to: 'schedules#index', as: :schedules
  #patch 'schedules', to: 'sch_transactions#update'

  get 'api/accounts/:id/details', to: 'api#account_details', as: :account_details
  get 'api/accounts/details', to: 'api#all_accounts_details', as: :account_all_details
  get 'api/format_currency/:amount(/:currency/:float)', to: 'api#format_currency'
  get 'api/convert_currency/:amount/:from/:to', to: 'api#convert_currency'
  get 'api/account_display_balance/:amount/:from/:to/:add', to: 'api#account_display_balance'
  get 'api/user_currency(/:detailed)', to: 'api#get_user_currency'
  get 'api/transactions/prepare_new/:date(/:account)', to: 'api#prepare_new_transaction'
  get 'api/transaction_date_ul/:date/:day_total/:account_currency', to: 'api#transaction_date_ul'
  get 'api/render_transaction/:t(/:account)', to: 'api#render_transaction'
  get 'api/render_transactionsmenu(/:account)', to: 'api#render_transactionsmenu'
  get 'api/account_currency(/:account)', to: 'api#get_account_currency'
  get 'api/currency_rate/:from/:to', to: 'api#get_currency_rate'
  get 'api/week_start', to: 'api#get_week_start', as: :week_start
  get 'api/currency_details/:currency', to: 'api#currency_details'
  get 'api/account_currency_details/:account_name', to: 'api#account_currency_details'
  get 'api/country_currency/:country_code', to: 'api#country_currency', as: :country_currency
  get 'api/schedule_transactions/:schedule_id', to: 'api#schedule_transactions'
  get 'api/get_next_schedule_date/:schedule_id', to: 'api#next_schedule_date'
  #get 'api/account_currency/:from_currency/:to_currency/:amount/'

  get 'api/next_occurrences/:type/:name/:start_date/:timezone/:schedule/:run_every/:days/:days2/:dates_picked/:weekday_mon/:weekday_tue/:weekday_wed/:weekday_thu/:weekday_fri/:weekday_sat/:weekday_sun/:end_date/:weekday_exclude_mon/:weekday_exclude_tue/:weekday_exclude_wed/:weekday_exclude_thu/:weekday_exclude_fri/:weekday_exclude_sat/:weekday_exclude_sun/:dates_picked_exclude/:exclusion_met1/:exclusion_met2/:occurrence_count', to: 'api#get_next_schedule_occurrences'
  get 'api/transfer_accounts/:from/:to', to: 'api#transfer_accounts'

  get 'app', to: 'app#index'
  get 'accounts/:id', to: 'accounts#show', as: :show_account
  post 'accounts/create_account', to: 'accounts#create_quick'
  post 'transactions', to: 'transactions#create'
  post 'schedules', to: 'schedules#create'
  devise_for :users, :controllers => { registrations: 'registrations' }
  resources :users, :only => [:create, :destroy, :edit]
  root 'welcome#index'
  get 'transactions/:id', to: 'transactions#show'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
