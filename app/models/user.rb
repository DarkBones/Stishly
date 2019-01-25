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
  has_many :setting_values, :as => :entity
  has_many :settings, through: :setting_values
  belongs_to :subscription_tier
  has_many :schedules
  has_many :categories
  has_many :transactions, through: :accounts

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
    entertainment = self.categories.create({
      name: "Entertainment",
      symbol: "entertainment",
      color: "0, 100%, 50%"
    })

    food_drinks = self.categories.create({
      name: "Food & Drinks",
      symbol: "food_drinks",
      color: "36, 100%, 50%"
    })

    health = self.categories.create({
      name: "Health",
      symbol: "health",
      color: "72, 100%, 50%"
    })

    household = self.categories.create({
      name: "Household",
      symbol: "house",
      color: "108, 100%, 50%"
    })

    income = self.categories.create({
      name: "Income",
      symbol: "income",
      color: "144, 100%, 50%"
    })

    investments = self.categories.create({
      name: "investments",
      symbol: "investments",
      color: "180, 100%, 50%"
    })

    other = self.categories.create({
      name: "Other",
      symbol: "others",
      color: "216, 100%, 50%"
    })

    shopping = self.categories.create({
      name: "Shopping",
      symbol: "shopping",
      color: "252, 100%, 50%"
    })

    transport = self.categories.create({
      name: "Transport",
      symbol: "transport",
      color: "288, 100%, 50%"
    })

    vehicle = self.categories.create({
      name: "Vehicle",
      symbol: "vehicle",
      color: "324, 100%, 50%"
    })

    self.categories.create([
      {
        name: "Cinema",
        symbol: "cinema",
        parent_id: entertainment.id,
        color: entertainment.color
      },
      {
        name: "Date",
        symbol: "date",
        parent_id: entertainment.id,
        color: entertainment.color
      },
      {
        name: "Hobbies",
        symbol: "hobbies",
        parent_id: entertainment.id,
        color: entertainment.color
      },
      {
        name: "Holiday",
        symbol: "holiday",
        parent_id: entertainment.id,
        color: entertainment.color
      },
      {
        name: "Lottery / Gambling",
        symbol: "lottery",
        parent_id: entertainment.id,
        color: entertainment.color
      },
      {
        name: "Social",
        symbol: "social",
        parent_id: entertainment.id,
        color: entertainment.color
      },
      {
        name: "Software",
        symbol: "software",
        parent_id: entertainment.id,
        color: entertainment.color
      },
      {
        name: "Sport Events",
        symbol: "sport_event",
        parent_id: entertainment.id,
        color: entertainment.color
      },
      {
        name: "Subscriptions",
        symbol: "subscription",
        parent_id: entertainment.id,
        color: entertainment.color
      },
      {
        name: "TV",
        symbol: "tv",
        parent_id: entertainment.id,
        color: entertainment.color
      },
      {
        name: "Video Games",
        symbol: "video_game",
        parent_id: entertainment.id,
        color: entertainment.color
      },
      {
        name: "Bars / Pubs",
        symbol: "bars_pubs",
        parent_id: food_drinks.id,
        color: food_drinks.color
      },
      {
        name: "Fast Food",
        symbol: "fast_food",
        parent_id: food_drinks.id,
        color: food_drinks.color
      },
      {
        name: "Groceries",
        symbol: "groceries",
        parent_id: food_drinks.id,
        color: food_drinks.color
      },
      {
        name: "Order / Take-out",
        symbol: "order_takeout",
        parent_id: food_drinks.id,
        color: food_drinks.color
      },
      {
        name: "Restaurant",
        symbol: "restaurant",
        parent_id: food_drinks.id,
        color: food_drinks.color
      },
      {
        name: "Dentist",
        symbol: "dentist",
        parent_id: health.id,
        color: health.color
      },
      {
        name: "Doctor",
        symbol: "doctor",
        parent_id: health.id,
        color: health.color
      },
      {
        name: "Insurance",
        symbol: "health_insurance",
        parent_id: health.id,
        color: health.color
      },
      {
        name: "Pharmacy",
        symbol: "pharmacy",
        parent_id: health.id,
        color: health.color
      },
      {
        name: "Psychiatrist",
        symbol: "psychiatrist",
        parent_id: health.id,
        color: health.color
      },
      {
        name: "Sport & Fitness",
        symbol: "fitness",
        parent_id: health.id,
        color: health.color
      },
      {
        name: "Wellness & Beauty",
        symbol: "wellness_beauty",
        parent_id: health.id,
        color: health.color
      },
      {
        name: "Electricity",
        symbol: "electricity",
        parent_id: household.id,
        color: household.color
      },
      {
        name: "Insurance",
        symbol: "house_insurance",
        parent_id: household.id,
        color: household.color
      },
      {
        name: "Internet",
        symbol: "internet",
        parent_id: household.id,
        color: household.color
      },
      {
        name: "Maintenance",
        symbol: "maintenance_household",
        parent_id: household.id,
        color: household.color
      },
      {
        name: "Mortgage",
        symbol: "mortgage",
        parent_id: household.id,
        color: household.color
      },
      {
        name: "Phone",
        symbol: "phone",
        parent_id: household.id,
        color: household.color
      },
      {
        name: "Rent",
        symbol: "rent",
        parent_id: household.id,
        color: household.color
      },
      {
        name: "Services",
        symbol: "services",
        parent_id: household.id,
        color: household.color
      },
      {
        name: "Water",
        symbol: "water",
        parent_id: household.id,
        color: household.color
      },
      {
        name: "Child Support",
        symbol: "child_support",
        parent_id: income.id,
        color: income.color
      },
      {
        name: "Gifts",
        symbol: "gifts",
        parent_id: income.id,
        color: income.color
      },
      {
        name: "Interest / Dividends",
        symbol: "interest_dividends",
        parent_id: income.id,
        color: income.color
      },
      {
        name: "Lending",
        symbol: "lending",
        parent_id: income.id,
        color: income.color
      },
      {
        name: "Lottery / Gambling",
        symbol: "lottery",
        parent_id: income.id,
        color: income.color
      },
      {
        name: "Refunds",
        symbol: "refunds",
        parent_id: income.id,
        color: income.color
      },
      {
        name: "Rent",
        symbol: "rent",
        parent_id: income.id,
        color: income.color
      },
      {
        name: "Salary",
        symbol: "salary",
        parent_id: income.id,
        color: income.color
      },
      {
        name: "Sale",
        symbol: "sale",
        parent_id: income.id,
        color: income.color
      },
      {
        name: "Financial Investments",
        symbol: "financial_investments",
        parent_id: investments.id,
        color: investments.color
      },
      {
        name: "Realty",
        symbol: "realty",
        parent_id: investments.id,
        color: investments.color
      },
      {
        name: "Savings",
        symbol: "savings",
        parent_id: investments.id,
        color: investments.color
      },
      {
        name: "Alcohol",
        symbol: "alcohol",
        parent_id: other.id,
        color: other.color
      },
      {
        name: "Charges & Fees",
        symbol: "charges_fees",
        parent_id: other.id,
        color: other.color
      },
      {
        name: "E-cigarette",
        symbol: "ecigarette",
        parent_id: other.id,
        color: other.color
      },
      {
        name: "Fines",
        symbol: "fines",
        parent_id: other.id,
        color: other.color
      },
      {
        name: "Insurance",
        symbol: "insurance",
        parent_id: other.id,
        color: other.color
      },
      {
        name: "Loans, Interest",
        symbol: "lending",
        parent_id: other.id,
        color: other.color
      },
      {
        name: "Postal Services",
        symbol: "postal_services",
        parent_id: other.id,
        color: other.color
      },
      {
        name: "Tobacco",
        symbol: "tobacco",
        parent_id: other.id,
        color: other.color
      },
      {
        name: "Books",
        symbol: "books",
        parent_id: shopping.id,
        color: shopping.color
      },
      {
        name: "Clothes & Shoes",
        symbol: "clothes",
        parent_id: shopping.id,
        color: shopping.color
      },
      {
        name: "Electronics",
        symbol: "electronics",
        parent_id: shopping.id,
        color: shopping.color
      },
      {
        name: "Gifts",
        symbol: "gifts",
        parent_id: shopping.id,
        color: shopping.color
      },
      {
        name: "Hobbies",
        symbol: "hobbies",
        parent_id: shopping.id,
        color: shopping.color
      },
      {
        name: "Home & Garden",
        symbol: "home_garden",
        parent_id: shopping.id,
        color: shopping.color
      },
      {
        name: "Jewellery & Accessories",
        symbol: "jewellery",
        parent_id: shopping.id,
        color: shopping.color
      },
      {
        name: "Kids",
        symbol: "kids",
        parent_id: shopping.id,
        color: shopping.color
      },
      {
        name: "Pets",
        symbol: "pets",
        parent_id: shopping.id,
        color: shopping.color
      },
      {
        name: "Tools",
        symbol: "tools",
        parent_id: shopping.id,
        color: shopping.color
      },
      {
        name: "Video Games",
        symbol: "video_game",
        parent_id: shopping.id,
        color: shopping.color
      },
      {
        name: "Flights",
        symbol: "flights",
        parent_id: transport.id,
        color: transport.color
      },
      {
        name: "Public Transport",
        symbol: "public_transport",
        parent_id: transport.id,
        color: transport.color
      },
      {
        name: "Taxi",
        symbol: "taxi",
        parent_id: transport.id,
        color: transport.color
      },
      {
        name: "Fuel",
        symbol: "fuel",
        parent_id: vehicle.id,
        color: vehicle.color
      },
      {
        name: "Insurance",
        symbol: "vehicle_insurance",
        parent_id: vehicle.id,
        color: vehicle.color
      },
      {
        name: "Lease",
        symbol: "lease",
        parent_id: vehicle.id,
        color: vehicle.color
      },
      {
        name: "Maintenance",
        symbol: "maintenance_vehicle",
        parent_id: vehicle.id,
        color: vehicle.color
      },
      {
        name: "Parking",
        symbol: "parking",
        parent_id: vehicle.id,
        color: vehicle.color
      },
      {
        name: "Rental",
        symbol: "rentals",
        parent_id: vehicle.id,
        color: vehicle.color
      }
    ])
  end
end
