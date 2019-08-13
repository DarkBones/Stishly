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
      put '/approve', to: 'transactions#approve', as: :approve_transaction
      put '/discard', to: 'transactions#discard'
      scope '/edit' do
        put '/', to: 'transactions#update', as: :edit_transaction
        scope '/upcoming' do
          scope '/occurrence' do
            patch '/', to: 'transactions#update_upcoming_occurrence', as: :edit_upcoming_transaction_occurrence
          end
          scope '/series' do
            patch '/', to: 'transactions#update_series', as: :edit_upcoming_transaction_series
          end
        end
      end
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
      scope '/transactions' do
        scope '/:id' do
          get '/', to: 'api_transactions#show'
          scope '/cancel_upcoming_occurrence' do
            scope '/:schedule_id/:schedule_period_id' do
              put '/', to: 'api_transactions#cancel_upcoming_occurrence'
            end
          end
          scope '/uncancel_upcoming_occurrence' do
            scope '/:schedule_id/:schedule_period_id' do
              put '/', to: 'api_transactions#uncancel_upcoming_occurrence'
            end
          end
          scope '/trigger_upcoming_occurrence' do
            scope '/:schedule_id/:schedule_period_id' do
              put '/', to: 'api_transactions#trigger_upcoming_occurrence'
            end
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
          scope '/unpause' do
            patch '/', to: 'api_schedules#unpause'
          end
          scope '/stop' do
            patch '/', to: 'api_schedules#stop'
          end
          scope '/activate' do
            patch '/', to: 'api_schedules#activate'
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
          scope '/upcoming' do
            scope '/edit_occurrence' do
              scope '/:id/:schedule_id/:schedule_period_id/:scheduled_transaction_id' do
                get '/', to: 'api_gui#edit_upcoming_transaction_occurrence_form'
              end
            end
            scope '/edit_series' do
              scope '/:id' do
                get '/', to: 'api_gui#edit_upcoming_transaction_series_form'
              end
            end
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
        scope '/left_menu' do
          get '/', to: 'api_gui#render_left_menu'
        end
        scope '/transaction' do
          scope '/:transaction' do
            get '/', to: 'api_gui#render_transaction'
          end
        end
        scope '/upcoming_transaction' do
          scope '/:id' do
            scope '/dropdown' do
              get '/', to: 'api_gui#render_upcoming_transaction_dropdown'
            end
          end
        end
        scope '/transaction_date' do
          scope '/:date/:day_total/:account_currency' do
            get '/', to: 'api_gui#render_transaction_date'
          end
        end
        scope '/schedules_table' do
          scope '/:type' do
            get '/', to: 'api_gui#render_schedules_table'
          end
        end
        scope '/swap_schedules_table' do # removes a schedule from a table and puts it in another table
          scope '/:schedule/:from' do
            get '/', to: 'api_gui#swap_schedules_table'
          end
        end
        scope '/schedule' do
          scope '/:id' do
            scope '/table_row' do
              get '/', to: 'api_gui#render_schedule_table_row'
            end
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
