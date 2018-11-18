Rails.application.routes.draw do
  #get 'users/index'
  #get 'users/show'
  get 'app', to: 'app#index'
  post 'app/create_account', to: 'app#create_account'
  devise_for :users, :controllers => { registrations: 'registrations' }
  resources :users, :accounts
  root 'welcome#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
