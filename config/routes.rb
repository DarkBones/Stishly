Rails.application.routes.draw do

  resources :account do
    collection do
      patch :sort
    end
  end

  get 'app', to: 'app#index'
  get 'account/:id', to: 'account#show'
  post 'account/create_account', to: 'account#create_quick'
  post 'transaction/create_transaction', to: 'transaction#create_quick'
  devise_for :users, :controllers => { registrations: 'registrations' }
  resources :users
  root 'welcome#index'
  
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
