Rails.application.routes.draw do

  resources :accounts do
    collection do
      patch :sort
    end
  end

  resource :transaction, only: [:show]
  resource :user_settings, only: [:edit]

  get 'accounts/:id/settings', to: 'accounts#settings', as: :account_settings

  post 'settings/edit', to: 'users#edit', as: :edit_settings
  get 'settings', to: 'users#settings'
  post 'accounts/:id/settings/edit', to: 'accounts#edit', as: :edit_account_settings
  get 'accounts/:id/set_default', to: 'accounts#set_default', as: :set_default_account
  get 'api/accounts/:id/details', to: 'accounts#details', as: :account_details
  get 'api/accounts/details', to: 'accounts#all_details', as: :account_all_details
  get 'api/format_currency/:amount/:currency', to: 'accounts#format_currency'
  get 'api/convert_currency/:amount/:from/:to', to: 'accounts#convert_currency'

  get 'app', to: 'app#index'
  get 'accounts/:id', to: 'accounts#show'
  post 'accounts/create_account', to: 'accounts#create_quick'
  post 'transaction/create_transaction', to: 'transaction#create'
  devise_for :users, :controllers => { registrations: 'registrations' }
  resources :users, :only => [:create, :destroy, :edit]
  root 'welcome#index'
  get 'transaction/:id', to: 'transaction#show'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
