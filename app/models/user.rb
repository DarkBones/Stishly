# == Schema Information
#
# Table name: users
#
#  id                     :bigint(8)        not null, primary key
#  first_name             :string(255)
#  last_name              :string(255)
#  subscription_tier_id   :bigint(8)        default(1)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  email                  :string(255)      default(""), not null
#  encrypted_password     :string(255)      default(""), not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  confirmation_token     :string(255)
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#  unconfirmed_email      :string(255)
#  failed_attempts        :integer          default(0), not null
#  unlock_token           :string(255)
#  locked_at              :datetime
#  timezone               :string(255)
#  country_code           :string(255)
#

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable
  has_many :accounts
  has_many :transactions, through: :accounts
  has_many :setting_values, :as => :entity
  has_many :settings, through: :setting_values
  belongs_to :subscription_tier
  has_many :schedules
  has_many :categories

  validates :country_code, :first_name, :last_name, presence: true

  after_create :set_categories

  # Returns the currency (string) of a user
  def self.get_currency(current_user)
    sett = SettingValue.get_setting(current_user, 'currency')
    if !sett
      return ISO3166::Country[current_user.country_code].currency
    else
      return Money::Currency.new(sett.value)
    end
  end

  def self.change_setting(current_user, params)
    sett_name = params[:setting_value].keys[0].to_s
    sett_value = params[:setting_value].values[0].to_s

    SettingValue.save_setting(current_user, {name: sett_name, value: sett_value})

    return current_user
  end

  def set_categories
    #self.categories.create([
    #  {name: "Repairs"}, 
    #  {name: "Supplies"}
    #])
    entertainment = self.categories.create({
      name: "Entertainment",
      symbol: "entertainment"
    })

    food_drinks = self.categories.create({
      name: "Food & Drinks",
      symbol: "food_drinks"
    })

    health = self.categories.create({
      name: "Health",
      symbol: "health"
    })

    household = self.categories.create({
      name: "Household",
      symbol: "household"
    })

    income = self.categories.create({
      name: "Income",
      symbol: "income"
    })

    investments = self.categories.create({
      name: "investments",
      symbol: "investments"
    })

    other = self.categories.create({
      name: "Other",
      symbol: "other"
    })

    shopping = self.categories.create({
      name: "Shopping",
      symbol: "shopping"
    })

    transport = self.categories.create({
      name: "Transport",
      symbol: "transport"
    })

    vehicle = self.categories.create({
      name: "Vehicle",
      symbol: "vehicle"
    })

    self.categories.create([
      {
        name: "Cinema",
        symbol: "cinema",
        parent_id: entertainment.id
      },
      {
        name: "Date",
        symbol: "date",
        parent_id: entertainment.id
      },
      {
        name: "Hobbies",
        symbol: "hobbies",
        parent_id: entertainment.id
      },
      {
        name: "Holiday",
        symbol: "holiday",
        parent_id: entertainment.id
      },
      {
        name: "Lottery / Gambling",
        symbol: "lottery",
        parent_id: entertainment.id
      },
      {
        name: "Social",
        symbol: "social",
        parent_id: entertainment.id
      },
      {
        name: "Software",
        symbol: "software",
        parent_id: entertainment.id
      },
      {
        name: "Sport Events",
        symbol: "sport_events",
        parent_id: entertainment.id
      },
      {
        name: "Subscriptions",
        symbol: "subscriptions",
        parent_id: entertainment.id
      },
      {
        name: "TV",
        symbol: "tv",
        parent_id: entertainment.id
      },
      {
        name: "Video Games",
        symbol: "video_games",
        parent_id: entertainment.id
      },
      {
        name: "Bars / Pubs",
        symbol: "bars_pubs",
        parent_id: food_drinks.id
      },
      {
        name: "Fast Food",
        symbol: "fast_food",
        parent_id: food_drinks.id
      },
      {
        name: "Groceries",
        symbol: "groceries",
        parent_id: food_drinks.id
      },
      {
        name: "Order / Take-out",
        symbol: "order_takeout",
        parent_id: food_drinks.id
      },
      {
        name: "Restaurant",
        symbol: "restaurant",
        parent_id: food_drinks.id
      },
      {
        name: "Dentist",
        symbol: "dentist",
        parent_id: health.id
      },
      {
        name: "Doctor",
        symbol: "doctor",
        parent_id: health.id
      },
      {
        name: "Insurance",
        symbol: "health_insurance",
        parent_id: health.id
      },
      {
        name: "Pharmacy",
        symbol: "pharmacy",
        parent_id: health.id
      },
      {
        name: "Psychiatrist",
        symbol: "psychiatrist",
        parent_id: health.id
      },
      {
        name: "Sport & Fitness",
        symbol: "sport_fitness",
        parent_id: health.id
      },
      {
        name: "Wellness & Beauty",
        symbol: "wellness_beauty",
        parent_id: health.id
      },
      {
        name: "Electricity",
        symbol: "electricity",
        parent_id: household.id
      },
      {
        name: "Insurance",
        symbol: "house_insurance",
        parent_id: household.id
      },
      {
        name: "Internet",
        symbol: "internet",
        parent_id: household.id
      },
      {
        name: "Maintenance",
        symbol: "maintenance_household",
        parent_id: household.id
      },
      {
        name: "Mortgage",
        symbol: "mortgage",
        parent_id: household.id
      },
      {
        name: "Phone",
        symbol: "phone",
        parent_id: household.id
      },
      {
        name: "Rent",
        symbol: "rent",
        parent_id: household.id
      },
      {
        name: "Services",
        symbol: "services",
        parent_id: household.id
      },
      {
        name: "Water",
        symbol: "water",
        parent_id: household.id
      },
      {
        name: "Child Support",
        symbol: "child_support",
        parent_id: income.id
      },
      {
        name: "Gifts",
        symbol: "gifts",
        parent_id: income.id
      },
      {
        name: "Interest / Dividends",
        symbol: "interest_dividends",
        parent_id: income.id
      },
      {
        name: "Lending",
        symbol: "lending",
        parent_id: income.id
      },
      {
        name: "Lottery / Gambling",
        symbol: "lottery",
        parent_id: income.id
      },
      {
        name: "Refunds",
        symbol: "refunds",
        parent_id: income.id
      },
      {
        name: "Rent",
        symbol: "rent",
        parent_id: income.id
      },
      {
        name: "Salary",
        symbol: "salary",
        parent_id: income.id
      },
      {
        name: "Sale",
        symbol: "sale",
        parent_id: income.id
      },
      {
        name: "Financial Investments",
        symbol: "financial_investments",
        parent_id: investments.id
      },
      {
        name: "Realty",
        symbol: "realty",
        parent_id: investments.id
      },
      {
        name: "Savings",
        symbol: "savings",
        parent_id: investments.id
      },
      {
        name: "Alcohol",
        symbol: "alcohol",
        parent_id: other.id
      },
      {
        name: "Charges & Fees",
        symbol: "charges_fees",
        parent_id: other.id
      },
      {
        name: "E-cigarette",
        symbol: "ecigarette",
        parent_id: other.id
      },
      {
        name: "Fines",
        symbol: "fines",
        parent_id: other.id
      },
      {
        name: "Insurance",
        symbol: "insurance",
        parent_id: other.id
      },
      {
        name: "Loans, Interest",
        symbol: "lending",
        parent_id: other.id
      },
      {
        name: "Postal Services",
        symbol: "postal_services",
        parent_id: other.id
      },
      {
        name: "Tobacco",
        symbol: "tobacco",
        parent_id: other.id
      },
      {
        name: "Books",
        symbol: "books",
        parent_id: shopping.id
      },
      {
        name: "Clothes & Shoes",
        symbol: "clothes",
        parent_id: shopping.id
      },
      {
        name: "Electronics",
        symbol: "electronics",
        parent_id: shopping.id
      },
      {
        name: "Gifts",
        symbol: "gifts",
        parent_id: shopping.id
      },
      {
        name: "Hobbies",
        symbol: "hobbies",
        parent_id: shopping.id
      },
      {
        name: "Home & Garden",
        symbol: "home_garden",
        parent_id: shopping.id
      },
      {
        name: "Jewellery & Accessories",
        symbol: "jewellery",
        parent_id: shopping.id
      },
      {
        name: "Kids",
        symbol: "kids",
        parent_id: shopping.id
      },
      {
        name: "Pets",
        symbol: "pets",
        parent_id: shopping.id
      },
      {
        name: "Tools",
        symbol: "tools",
        parent_id: shopping.id
      },
      {
        name: "Video Games",
        symbol: "video_games",
        parent_id: shopping.id
      },
      {
        name: "Flights",
        symbol: "flight",
        parent_id: transport.id
      },
      {
        name: "Public Transport",
        symbol: "public_transport",
        parent_id: transport.id
      },
      {
        name: "Taxi",
        symbol: "taxi",
        parent_id: transport.id
      },
      {
        name: "Fuel",
        symbol: "fuel",
        parent_id: vehicle.id
      },
      {
        name: "Insurance",
        symbol: "vehicle_insurance",
        parent_id: vehicle.id
      },
      {
        name: "Lease",
        symbol: "lease",
        parent_id: vehicle.id
      },
      {
        name: "Maintenance",
        symbol: "vehicle_maintenance",
        parent_id: vehicle.id
      },
      {
        name: "Parking",
        symbol: "parking",
        parent_id: vehicle.id
      },
      {
        name: "Rental",
        symbol: "rentals",
        parent_id: vehicle.id
      },
    ])
  end
end
