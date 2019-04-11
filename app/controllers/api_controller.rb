class ApiController < ApplicationController

  # renders the details of a given account name
  def account_details
    @account = current_user.accounts.where(name: params[:id]).take

    if @account
      @account = @account.decorate if @account
      render json: {
        id: @account.id,
        balance: @account.balance,
        balance_float: @account.balance_float,
        created_at: @account.created_at,
        updated_at: @account.updated_at,
        name: @account.name,
        description: @account.description,
        currency: @account.currency
      }
    end
  end

  # renders the iso code of the currency of the given account name
  def country_currency
    currency = ISO3166::Country[params[:country_code]].currency
    iso_code = ""
    iso_code = currency.iso_code unless currency.nil?
    render json: iso_code
  end

  # returns the user's start of the week (0 to 6)
  def get_week_start
    render json: current_user.country.week_start
  end

  # gets the currency rates between two given accounts, for transferring purposes
  def transfer_accounts
    from_account = Account.get_from_name(params[:from], current_user)
    to_account = Account.get_from_name(params[:to], current_user)

    currency_rate = 1

    if from_account.currency != to_account.currency
      currency_rate = CurrencyRate.get_rate(from_account.currency, to_account.currency)
    end

    render json: {
      from_account: {
        currency: from_account.currency
      },
      to_account: {
        currency: to_account.currency
      },
      currency_rate: currency_rate
    }
  end

  # returns the next scheduled occurrences of a given schedule
  def get_next_schedule_occurrences
    schedule = Schedule.create_from_form({schedule: schedule_params}, current_user)
    
    occurrences = []
    if schedule.is_a?(ActiveRecord::Base)
      next_occurrence = params[:start_date].to_date
      params[:occurrence_count].to_i.times do
        next_occurrence = Schedule.next_occurrence(schedule, next_occurrence)

        unless next_occurrence.nil?
          occurrences.push(("<li>"+User.format_date(next_occurrence, true)+"</li>").html_safe)

          next_occurrence += 1
        else
          break
        end
      end
    else
      occurrences.push(("<p id='next_occurrence_error'>ERROR: #{schedule}</p>").html_safe)
    end

    render json: occurrences
  end

  # render the new transaction menu
  def render_transactionsmenu
    @active_account
    if params[:account]
      @active_account = Account.get_from_name(params[:account], current_user)
    end

    render partial: "card_forms/new_transaction_form", locals: {active_account: @active_account}
  end

  # renders the exchange rate between two given currencies
  def get_currency_rate
    render json: CurrencyRate.get_rate(params[:from], params[:to])
  end

  # renders the details of all of the user's accounts
  def all_accounts_details
    @accounts = Account.get_accounts(current_user)

    render json: @accounts
  end

  # renders the currency details of a given account
  def account_currency_details
    account = Account.get_from_name(params[:account_name], current_user)
    currency = Money::Currency.new(account.currency)
    render json: currency
  end

  # renders the details of a given currency
  def currency_details
    currency = Money::Currency.new(params[:currency])
    render json: currency
  end

  # renders the transaction date section
  def transaction_date_ul
    date_formatted = User.format_date(params[:date].to_date)
    render partial: 'accounts/transactions_date', :locals => { :d => params[:date], :account_currency => params[:account_currency], :day_total => params[:day_total], :d_formatted => date_formatted }
  end

  # renders a transaction
  def render_transaction
    active_account = Account.get_from_name(params[:account], current_user)
    t = current_user.transactions.find(params[:t]).decorate

    render partial: 'accounts/transaction', :locals => { :active_account => active_account, :t => t }
  end

  # formats a given amount according to the given currency
  def format_currency
    if params[:float]
      render json: Account.format_currency_float(params[:amount].sub('$', '.'), params[:currency])
    else
      render json: Account.format_currency(params[:amount], params[:currency])
    end
  end

  # converts two different currencies
  def convert_currency
    render json: CurrencyRate.convert(params[:amount], Money::Currency.new(params[:from]), Money::Currency.new(params[:to]))
  end

  # renders the balance of a given account
  def account_display_balance
    render json: Account.get_display_balance_html(params)
  end

  # renders the iso code of the user's currency
  def get_user_currency
    render json: User.get_currency(current_user).iso_code
  end

  # renders the iso code of the currency of the given account
  def get_account_currency
    if params[:account]
      render json: Account.get_currency_from_name(params[:account], current_user).iso_code
    else
      render json: User.get_currency(current_user).iso_code
    end
  end

  # prepares a transaction to be shown in the user's format
  def prepare_new_transaction
    render json: Transaction.prepare_new(params, current_user)
  end

private
  
  def schedule_params
    params.permit(
      :name,
      :type,
      :start_date,
      :timezone,
      :schedule,
      :run_every,
      :days,
      :days2,
      :dates_picked,
      :weekday_mon,
      :weekday_tue,
      :weekday_wed,
      :weekday_thu,
      :weekday_fri,
      :weekday_sat,
      :weekday_sun,
      :end_date,
      :weekday_exclude_mon,
      :weekday_exclude_tue,
      :weekday_exclude_wed,
      :weekday_exclude_thu,
      :weekday_exclude_fri,
      :weekday_exclude_sat,
      :weekday_exclude_sun,
      :dates_picked_exclude,
      :exclusion_met1,
      :exclusion_met2,
      :occurrence_count
      )
  end

end
