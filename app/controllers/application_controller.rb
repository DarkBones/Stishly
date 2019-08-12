class ApplicationController < ActionController::Base
  before_action :authenticate_user!, :except => [:country_currency, :privacy_policy, :api]
  before_action :set_current_user, :setup_wizzard

  helper_method :user_accounts, :user_accounts_array, :user_categories_array, :user_schedules_array

  def setup_wizzard
    if user_signed_in?
      unless current_user.finished_setup
        redirect_to user_welcome_path unless request.original_fullpath.start_with?('/users') || request.original_fullpath.start_with?('/api') || request.original_fullpath.start_with?('/registrations')
      end
    end
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
      accounts.push(["#{a.name} (#{a.currency})", a.name]) if a.id > 0
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

  private

  def valid_timezone(tz)
    return !tz.nil? && ActiveSupport::TimeZone[tz].present?

  end

end
