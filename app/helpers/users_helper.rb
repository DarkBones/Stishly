module UsersHelper
  def user_currency
    ISO3166::Country[current_user.country_code].currency
  end
end
