Rails.application.routes.draw do

  resources :accounts do
    collection do
      patch :sort
    end
  end

  scope '/accounts' do
    scope '/:id' do
      get '/', to: 'accounts#show', as: :show_account
      scope '/settings' do
        get '/', to: 'accounts#settings', as: :account_settings
        scope '/edit' do
          post '/', to: 'accounts#edit', as: :edit_account_settings
        end
      end
    end
  end

  scope '/transactions' do
    post '/', to: 'transactions#create'
    scope '/:id' do
      get '/', to: 'transactions#show'
      put '/edit', to: 'transactions#update', as: :edit_transaction
      put '/approve', to: 'transactions#approve', as: :approve_transaction
      put '/discard', to: 'transactions#discard'
    end
  end

  scope '/upcoming_transactions' do
    get '/', to: 'transactions#upcoming_transactions', as: :upcoming_transactions
  end

  scope '/queued_transactions' do
    get '/', to: 'transactions#queued'
  end

  scope '/users' do
    scope '/welcome' do
      get '/', to: 'users#welcome', as: :user_welcome
    end
    scope '/submit_setup' do
      post '/', to: 'users#submit_setup'
    end
    scope '/settings' do
      get '/', to: 'users#settings', as: :user_settings
      scope 'edit' do
        post '/', to: 'users#edit', as: :edit_settings
      end
    end
  end

  scope '/schedules' do
    get '/', to: 'schedules#index', as: :schedules
    post '/', to: 'schedules#create'
    scope '/:id' do
      scope '/pause' do
        patch '/', to: 'schedules#pause', as: :pause_schedule
      end
      scope '/edit' do
        patch '/', to: 'schedules#edit', as: :schedule
      end
    end
  end

  scope '/api' do
    scope '/v1' do

      scope '/accounts' do
        get '/', to: 'api_accounts#index'
        scope '/:account' do
          get '/', to: 'api_accounts#show'
          scope '/currency' do
            get '/', to: 'api_accounts#currency'
          end
        end
      end
      scope '/account_display_balance/:amount/:from/:to/:add' do
        get '/', to: 'api_gui#account_display_balance'
      end
      scope '/currencies' do
        get '/', to: 'api_currencies#index'
        scope '/:currency' do
          get '/', to: 'api_currencies#show'
          scope '/convert/:amount/:to_currency' do
            get '/', to: 'api_currencies#convert'
          end
          scope '/rate/:to_currency' do
            get '/', to: 'api_currencies#rate'
          end
          scope '/format/:amount' do
            get '/', to: 'api_currencies#format'
          end
        end
      end
      scope 'currencies_transfer_rate' do
        scope '/:from/:to' do
          get '/', to: 'api_currencies#transfer_rate'
        end
      end
      scope '/countries' do
        get '/', to: 'api_countries#index'
        scope '/:country' do
          get '/', to: 'api_countries#show'
          scope '/currency' do
            get '/', to: 'api_countries#currency'
          end
        end
      end
      scope '/schedules' do
        get '/', to: 'api_schedules#index'
        scope '/:schedule' do
          get '/', to: 'api_schedules#show'
          scope '/transactions' do
            get '/', to: 'api_schedules#transactions'
          end
          scope '/next_occurrence' do
            get '/', to: 'api_schedules#next_occurrence'
            scope '/:count' do
              get '/', to: 'api_schedules#next_occurrences'
            end
          end
        end
      end
      scope '/users' do
        scope '/subscription' do
          get '/', to: 'api_users#subscription'
        end
        scope '/currency' do
          get '/', to: 'api_users#currency'
        end
        scope '/week_start' do
          get '/', to: 'api_users#week_start'
        end
      end
      scope '/next_schedule_occurrence' do
        scope '/:count/:type/:start_date/:timezone/:schedule/:run_every/:days/:days2/:dates_picked/:weekday_mon/:weekday_tue/:weekday_wed/:weekday_thu/:weekday_fri/:weekday_sat/:weekday_sun/:end_date/:weekday_exclude_mon/:weekday_exclude_tue/:weekday_exclude_wed/:weekday_exclude_thu/:weekday_exclude_fri/:weekday_exclude_sat/:weekday_exclude_sun/:dates_picked_exclude/:exclusion_met1/:exclusion_met2/' do
          get '/', to: 'api_schedules#next_occurrences_from_form'
        end
      end
      scope '/notifications' do
        scope '/render' do
          get '/', to: 'api_gui#render_notifications'
        end
      end
      scope '/forms' do
        scope '/accounts' do
          scope '/new' do
            get '/', to: 'api_gui#new_account_form'
          end
        end
        scope '/transactions' do
          scope '/new' do
            get '/', to: 'api_gui#new_transaction_form'
          end
        end
        scope '/schedules' do
          scope '/new' do
            get '/', to: 'api_gui#new_schedule_form'
          end
          scope '/edit/:id' do
            get '/', to: 'api_gui#edit_schedule_form'
          end
          scope '/transactions' do
            get '/:schedule', to: 'api_gui#render_schedule_transactions'
          end
          scope '/pause/:id' do
            get '/', to: 'api_gui#render_schedule_pauseform'
          end
        end
      end
      scope '/render' do
        scope '/transaction' do
          scope '/:transaction' do
            get '/', to: 'api_gui#render_transaction'
          end
        end
        scope '/transaction_date' do
          scope '/:date/:day_total/:account_currency' do
            get '/', to: 'api_gui#render_transaction_date'
          end
        end
      end

    end
  end

  resource :transactions, only: [:index, :show]
  resource :user_settings, only: [:edit]
  resource :schedules_transactions
  resource :notifications

  devise_for :users, :controllers => { registrations: 'registrations', omniauth_callbacks: 'users/omniauth_callbacks' }
  resources :users, :only => [:create, :destroy, :edit]

  get '/privacy', to: 'application#privacy_policy', as: :privacy_policy

  get 'app', to: 'app#index'

  root 'welcome#index'
  
end
