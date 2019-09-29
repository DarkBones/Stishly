Rails.application.routes.draw do

  resources :accounts do
    collection do
      patch :sort
    end
  end

  scope '/accounts' do
    get '/', to: 'accounts#index'
    scope '/:id' do
      get '/', to: 'accounts#show', as: :show_account
      delete '/', to: 'accounts#destroy', as: :delete_account
      scope '/settings' do
        get '/', to: 'accounts#settings', as: :account_settings
        scope '/edit' do
          post '/', to: 'accounts#edit', as: :edit_account_settings
        end
      end
      scope '/overview' do
        get '/', to: 'accounts#overview', as: :account_overview
      end
    end
  end
  scope '/accounts_overview' do
    get '/', to: 'accounts#overview_all', as: :account_all_overview
  end

  scope '/categories' do
    get '/', to: 'categories#index', as: :categories
    scope '/sort' do
      patch '/', to: 'categories#sort'
    end
    scope '/create' do
      post '/', to: 'categories#create', as: :new_category
    end
    scope '/edit' do
      scope '/:id' do
        patch '/', to: 'categories#update', as: :edit_category
      end
    end
  end

  scope '/transactions' do
    post '/', to: 'transactions#create'
    scope '/:id' do
      get '/', to: 'transactions#show'
      put '/approve', to: 'transactions#approve', as: :approve_transaction
      put '/discard', to: 'transactions#discard'
      delete '/', to: 'transactions#delete', as: :delete_transaction
      scope '/edit' do
        patch '/', to: 'transactions#update', as: :edit_transaction
        scope '/upcoming' do
          scope '/occurrence' do
            patch '/', to: 'transactions#update_upcoming_occurrence', as: :edit_upcoming_transaction_occurrence
          end
          scope '/series' do
            patch '/', to: 'transactions#update_series', as: :edit_upcoming_transaction_series
          end
        end
        scope '/scheduled' do
          patch '/', to: 'transactions#update_scheduled', as: :edit_scheduled_transaction
        end
      end
    end
    scope '/mass_delete' do
      delete '/(:ids)', to: 'transactions#mass_delete', as: :mass_delete_transactions
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
    delete '/', to: 'schedules#delete_all'
    scope '/:id' do
      scope '/pause' do
        patch '/', to: 'schedules#pause', as: :pause_schedule
      end
      scope '/edit' do
        patch '/', to: 'schedules#edit', as: :schedule
      end
      scope '/transactions' do
        scope '/create' do
          post '/', to: 'transactions#create_scheduled', as: :create_scheduled_transaction
        end
        scope '/edit' do
          put '/:transaction_id', to: 'transactions#update'
        end
      end
      scope '/delete' do
        delete '/', to: 'schedules#delete', as: :delete_schedule
      end
    end
  end

  # /api
  scope '/api' do
    #/api/v1
    scope '/v1' do
      #/api/v1/accounts
      scope '/accounts' do
        get '/', to: 'api_accounts#index'
        #api/v1/accounts/:account
        scope '/:account' do
          get '/', to: 'api_accounts#show'
          #api/v1/accounts/:account/currency
          scope '/currency' do
            get '/', to: 'api_accounts#currency'
          end
        end
      end
      #/api/v1/transactions
      scope '/transactions' do
        #/api/v1/transactions/:id
        scope '/:id' do
          get '/', to: 'api_transactions#show'
          #/api/v1/transactions/:id/cancel_upcoming_occurrence/:schedule_id/:schedule_period_id
          scope '/cancel_upcoming_occurrence' do
            scope '/:schedule_id/:schedule_period_id' do
              put '/', to: 'api_transactions#cancel_upcoming_occurrence'
            end
          end
          #/api/v1/transactions/:id/uncancel_upcoming_occurrence/:schedule_id/:schedule_period_id
          scope '/uncancel_upcoming_occurrence' do
            scope '/:schedule_id/:schedule_period_id' do
              put '/', to: 'api_transactions#uncancel_upcoming_occurrence'
            end
          end
          #/api/v1/transactions/:id/trigger_upcoming_occurrence/:schedule_id/:schedule_period_id
          scope '/trigger_upcoming_occurrence' do
            scope '/:schedule_id/:schedule_period_id' do
              put '/', to: 'api_transactions#trigger_upcoming_occurrence'
            end
          end
        end
      end
      #/api/v1/account_display_balance/:amount/:from/:to/:add
      scope '/account_display_balance/:amount/:from/:to/:add' do
        get '/', to: 'api_gui#account_display_balance'
      end
      #/api/v1/categories
      scope '/categories' do
        #/api/v1/categories/:id
        scope '/:id' do
          #/api/v1/categories/:id/delete
          scope '/delete' do
            delete '/', to: 'api_categories#delete'
          end
          #/api/v1/categories/:id/transaction_count
          scope '/transaction_count' do
            get '/', to: 'api_categories#transaction_count'
          end
        end
      end
      #/api/v1/currencies
      scope '/currencies' do
        get '/', to: 'api_currencies#index'
        #/api/v1/currencies/:currency
        scope '/:currency' do
          get '/', to: 'api_currencies#show'
          #/api/v1/currencies/:currency/convert/:amount/:to_currency
          scope '/convert/:amount/:to_currency' do
            get '/', to: 'api_currencies#convert'
          end
          #/api/v1/currencies/:currency/rate/:to_currency
          scope '/rate/:to_currency' do
            get '/', to: 'api_currencies#rate'
          end
          #/api/v1/currencies/:currency/format/:amount
          scope '/format/:amount' do
            get '/', to: 'api_currencies#format'
          end
        end
      end
      #/api/v1/currencies_transfer_rate/:from/:to
      scope 'currencies_transfer_rate' do
        scope '/:from/:to' do
          get '/', to: 'api_currencies#transfer_rate'
        end
      end
      #/api/v1/countries
      scope '/countries' do
        get '/', to: 'api_countries#index'
        #/api/v1/countries/:country
        scope '/:country' do
          get '/', to: 'api_countries#show'
          #/api/v1/countries/:country/currency
          scope '/currency' do
            get '/', to: 'api_countries#currency'
          end
        end
      end
      #/api/v1/schedules
      scope '/schedules' do
        get '/', to: 'api_schedules#index'
        #/api/v1/schedules/:schedule
        scope '/:schedule' do
          get '/', to: 'api_schedules#show'
          #/api/v1/schedules/:schedule/transactions
          scope '/transactions' do
            get '/', to: 'api_schedules#transactions'
          end
          #/api/v1/schedules/:schedule/next_occurrence(/:count)
          scope '/next_occurrence' do
            get '/', to: 'api_schedules#next_occurrence'
            scope '/:count' do
              get '/', to: 'api_schedules#next_occurrences'
            end
          end
          #/api/v1/schedules/:schedule/unpause
          scope '/unpause' do
            patch '/', to: 'api_schedules#unpause'
          end
          #/api/v1/schedules/:schedule/stop
          scope '/stop' do
            patch '/', to: 'api_schedules#stop'
          end
          #/api/v1/schedules/:schedule.activate
          scope '/activate' do
            patch '/', to: 'api_schedules#activate'
          end
        end
      end
      #/api/v1/users
      scope '/users' do
        #/api/v1/users/subscription
        scope '/subscription' do
          get '/', to: 'api_users#subscription'
        end
        #/api/v1/users/currency
        scope '/currency' do
          get '/', to: 'api_users#currency'
        end
        #/api/v1/users/week_start
        scope '/week_start' do
          get '/', to: 'api_users#week_start'
        end
      end
      #/api/v1/next_schedule_occurrence/:schedule_params
      scope '/next_schedule_occurrence' do
        scope '/:count/:type/:start_date/:timezone/:schedule/:run_every/:days/:days2/:dates_picked/:weekday_mon/:weekday_tue/:weekday_wed/:weekday_thu/:weekday_fri/:weekday_sat/:weekday_sun/:end_date/:weekday_exclude_mon/:weekday_exclude_tue/:weekday_exclude_wed/:weekday_exclude_thu/:weekday_exclude_fri/:weekday_exclude_sat/:weekday_exclude_sun/:dates_picked_exclude/:exclusion_met1/:exclusion_met2/' do
          get '/', to: 'api_schedules#next_occurrences_from_form'
        end
      end
      #/api/v1/notifications
      scope '/notifications' do
        #/api/v1/notifications/render
        scope '/render' do
          get '/', to: 'api_gui#render_notifications'
        end
      end
      #/api/v1/forms
      scope '/forms' do
        #/api/v1/forms/edit_category/:id
        scope '/edit_category' do
          scope '/:id' do
            get '/', to: 'api_gui#edit_category_form'
          end
        end
        #/api/v1/forms/accounts
        scope '/accounts' do
          #/api/v1/forms/accounts/new
          scope '/new' do
            get '/', to: 'api_gui#new_account_form'
          end
        end
        #/api/v1/forms/transactions
        scope '/transactions' do
          #/api/v1/forms/transactions/new
          scope '/new' do
            get '/', to: 'api_gui#new_transaction_form'
          end
          #/api/v1/forms/transactions/upcoming
          scope '/upcoming' do
            #/api/v1/forms/transactions/upcoming/edit_occurrence
            scope '/edit_occurrence' do
              #/api/v1/forms/transactions/upcoming/edit_occurrence/:id/:schedule_id/:schedule_period_id/:schedule_transaction_id
              scope '/:id/:schedule_id/:schedule_period_id/:scheduled_transaction_id' do
                get '/', to: 'api_gui#edit_upcoming_transaction_occurrence_form'
              end
            end
            #/api/v1/forms/transactions/upcoming/edit_series
            scope '/edit_series' do
              #/api/v1/forms/transactions/upcoming/edit_series/:id
              scope '/:id' do
                get '/', to: 'api_gui#edit_upcoming_transaction_series_form'
              end
            end
          end
          #/api/v1/forms/transactions/edit
          scope '/edit' do
            scope '/:id' do
              get '/', to: 'api_gui#edit_transaction'
            end
          end
        end
        #/api/v1/forms/schedules
        scope '/schedules' do
          #/api/v1/forms/schedules/new
          scope '/new' do
            get '/', to: 'api_gui#new_schedule_form'
          end
          #/api/v1/forms/schedules/edit
          scope '/edit/:id' do
            get '/', to: 'api_gui#edit_schedule_form'
          end
          #/api/v1/forms/schedules/transactions/:schedule
          scope '/transactions' do
            get '/:schedule', to: 'api_gui#render_schedule_transactions'
          end
          #/api/v1/forms/schedules/pause/:id
          scope '/pause/:id' do
            get '/', to: 'api_gui#render_schedule_pauseform'
          end
        end
      end
      #/api/v1/render
      scope '/render' do
        #/api/v1/render/account_overview_charts/:start/:end(/:account)
        scope '/account_overview_charts/:start/:end(/:account)' do
          get '/', to: 'api_gui#render_account_overview_charts'
        end
        #/api/v1/render/account_title_balance(/:account)
        scope '/account_title_balance/' do
          scope '(/:account)' do
            get '/', to: 'api_gui#render_account_title_balance'
          end
        end
        #/api/v1/render/left_menu
        scope '/left_menu' do
          get '/', to: 'api_gui#render_left_menu'
        end
        #/api/v1/render/create_transaction/:transaction_id/(:account_name)
        scope '/create_transaction' do
          get '/:transaction_id/(:account_name)', to: 'api_gui#create_transaction'
        end
        #/api/v1/render/transaction/:transaction
        scope '/transaction' do
          scope '/:transaction' do
            get '/', to: 'api_gui#render_transaction'
          end
        end
        #/api/v1/render/upcoming_transaction/:id/dropdown
        scope '/upcoming_transaction' do
          scope '/:id' do
            scope '/dropdown' do
              get '/', to: 'api_gui#render_upcoming_transaction_dropdown'
            end
          end
        end
        #/api/v1/render/transaction_date/:date(/:account)
        scope '/transaction_date' do
          scope '/:date/(:account)' do
            get '/', to: 'api_gui#render_transaction_date'
          end
        end
        #/api/v1/render/schedules_table/:type
        scope '/schedules_table' do
          scope '/:type' do
            get '/', to: 'api_gui#render_schedules_table'
          end
        end
        #/api/v1/render/swap_schedules_table/:schedule/:from
        scope '/swap_schedules_table' do # removes a schedule from a table and puts it in another table
          scope '/:schedule/:from' do
            get '/', to: 'api_gui#swap_schedules_table'
          end
        end
        #/api/v1/render/schedule
        scope '/schedule' do
          #/api/v1/render/schedule/:id
          scope '/:id' do
            #/api/v1/render/schedule/:id/table_row
            scope '/table_row' do
              get '/', to: 'api_gui#render_schedule_table_row'
            end
          end
        end
        #/api/v1/render/scheduled_transaction/:id
        scope '/scheduled_transaction' do
          scope '/:id' do
            get '/', to: 'api_gui#render_scheduled_transaction'
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
