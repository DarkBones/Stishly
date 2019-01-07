Rails.application.routes.draw do

  resources :account do
    collection do
      patch :sort
    end
  end

  resource :transaction, only: [:show]
  resource :user_settings, only: [:edit]

  get 'account/:id/settings', to: 'account#settings', as: :account_settings

  post 'settings/edit', to: 'users#edit', as: :edit_settings
  get 'settings', to: 'users#settings'
  post 'account/:id/settings/edit', to: 'account#edit', as: :edit_account_settings
  get 'account/:id/set_default', to: 'account#set_default', as: :set_default_account

  get 'app', to: 'app#index'
  get 'account/:id', to: 'account#show'
  post 'account/create_account', to: 'account#create_quick'
  post 'transaction/create_transaction', to: 'transaction#create_quick'
  devise_for :users, :controllers => { registrations: 'registrations' }
  resources :users, :only => [:create, :destroy, :edit]
  root 'welcome#index'
  get 'transaction/:id', to: 'transaction#show'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
