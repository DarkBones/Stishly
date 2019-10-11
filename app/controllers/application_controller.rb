class ApplicationController < ActionController::Base
  before_action :authenticate_user!, :except => [:country_currency, :privacy_policy, :api]
  before_action :set_current_user, :setup_wizzard, :check_subscription
  before_action :daily_budget

  helper_method :user_accounts, :user_accounts_array, :user_categories_array, :user_schedules_array

  # check if a user's subscription is still valid
  def check_subscription
    return if current_user.nil?
    
    last_check = current_user.last_plan_check
    return if last_check > 1.days.ago unless last_check.nil?

    s = User.get_subscription(current_user)
    if s.nil?
      unless current_user.subscription == 'free'
        Subscription.cancel(current_user)
      end
    else
      if current_user.subscription == 'free'

        plan_id = s[:plan][:id]

        plan = StripePlan.where(plan_id_month: plan_id).take
        plan ||= StripePlan.where(plan_id_month_no_trial: plan_id).take
        unless plan.nil?
          current_user.subscription = 'monthly'
        end

        plan = StripePlan.where(plan_id_year: plan_id).take
        plan ||= StripePlan.where(plan_id_year_no_trial: plan_id).take
        unless plan.nil?
          current_user.subscription = 'yearly'
        end

        current_user.accounts.where(is_disabled: true).each do |a|
          a.is_disabled = false
          a.save
        end

      end
    end

    current_user.last_plan_check = Time.now.utc
    current_user.save
  end

  def setup_wizzard
    if user_signed_in?
      unless current_user.finished_setup
        redirect_to user_welcome_path unless request.original_fullpath.start_with?('/users') || request.original_fullpath.start_with?('/api') || request.original_fullpath.start_with?('/registrations')
      end
    end
  end

  def daily_budget
    if user_signed_in?
      if current_user.finished_setup
        #@budget = User.daily_budget(current_user)
      end
    end
    @budget = User.daily_budget(current_user)
  end

  def privacy_policy
    render "application/privacy"
  end

  def get_accounts_currencies
    @accounts_currencies = Account.get_accounts_with_currencies(current_user)
  end

  def set_current_user
    User.set_current_user(current_user)
  end

  def user_accounts
    @user_accounts = Account.get_accounts(current_user)
    OpenStruct.new(
      accounts: @user_accounts
      )
  end

  def user_accounts_array
    accounts = []

    Account.get_accounts(current_user).each do |a|
      accounts.push(["#{a.name} (#{a.currency})", a.name]) if a.id > 0 && a.is_disabled == false
    end

    return accounts
  end

  def user_schedules_array
    schedules = []

    current_user.schedules.each do |s|
      schedules.push([s.name, s.id])
    end

    return schedules
  end

  def user_categories_array
    categories = []

    current_user.categories.each do |c|
      categories.push("<b>" + c.symbol + "</b>".html_safe)
    end

    return categories
  end

  def validate_timezone(tz)
    if !tz.nil? && ActiveSupport::TimeZone[tz].present?
      return TZInfo::Timezone.get(tz)
    else
      return TZInfo::Timezone.get("Europe/London")
    end
  end

  def not_found
    raise ActionController::RoutingError.new('Not Found')
  end

  private

  def valid_timezone(tz)
    return !tz.nil? && ActiveSupport::TimeZone[tz].present?

  end


end
