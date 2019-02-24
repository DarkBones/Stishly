Rails.application.routes.draw do

  resources :accounts do
    collection do
      patch :sort
    end
  end

  resource :transactions, only: [:show]
  resource :user_settings, only: [:edit]

  get 'accounts/:id/settings', to: 'accounts#settings', as: :account_settings

  post 'settings/edit', to: 'users#edit', as: :edit_settings
  get 'settings', to: 'users#settings'
  post 'accounts/:id/settings/edit', to: 'accounts#edit', as: :edit_account_settings
  get 'accounts/:id/set_default', to: 'accounts#set_default', as: :set_default_account

  get 'api/accounts/:id/details', to: 'api#account_details', as: :account_details
  get 'api/accounts/details', to: 'api#all_accounts_details', as: :account_all_details
  get 'api/format_currency/:amount/:currency(/:float)', to: 'api#format_currency'
  get 'api/convert_currency/:amount/:from/:to', to: 'api#convert_currency'
  get 'api/account_display_balance/:amount/:from/:to/:add', to: 'api#account_display_balance'
  get 'api/user_currency', to: 'api#get_user_currency'
  get 'api/transactions/prepare_new/:date(/:account)', to: 'api#prepare_new_transaction'
  get 'api/transaction_date_ul/:date/:day_total/:account_currency', to: 'api#transaction_date_ul'
  get 'api/render_transaction/:t(/:account)', to: 'api#render_transaction'
  get 'api/render_transactionsmenu(/:account)', to: 'api#render_transactionsmenu'
  get 'api/account_currency(/:account)', to: 'api#get_account_currency'
  get 'api/currency_rate/:from/:to', to: 'api#get_currency_rate'
  #get 'api/account_currency/:from_currency/:to_currency/:amount/'

  get 'app', to: 'app#index'
  get 'accounts/:id', to: 'accounts#show'
  post 'accounts/create_account', to: 'accounts#create_quick'
  post 'transactions', to: 'transactions#create'
  devise_for :users, :controllers => { registrations: 'registrations' }
  resources :users, :only => [:create, :destroy, :edit]
  root 'welcome#index'
  get 'transactions/:id', to: 'transactions#show'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
