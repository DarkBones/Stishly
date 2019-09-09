class User
  class InitializeUserData

    def initialize(current_user)
      @current_user = current_user
    end

    def perform
      create_categories
    end

private
    
    def create_categories

      entertainment = @current_user.categories.create({
        name: "Entertainment",
        symbol: "theater-masks",
        color: "0, 100%, 50%"
      })

      food_drinks = @current_user.categories.create({
        name: "Food & Drinks",
        symbol: "utensils",
        color: "36, 100%, 50%"
      })

      health = @current_user.categories.create({
        name: "Health",
        symbol: "heartbeat",
        color: "72, 100%, 50%"
      })

      household = @current_user.categories.create({
        name: "Household",
        symbol: "home",
        color: "108, 100%, 50%"
      })

      income = @current_user.categories.create({
        name: "Income",
        symbol: "coins",
        color: "144, 100%, 50%"
      })

      investments = @current_user.categories.create({
        name: "investments",
        symbol: "file-invoice-dollar",
        color: "180, 100%, 50%"
      })

      other = @current_user.categories.create({
        name: "Other",
        symbol: "ellipsis-h",
        color: "216, 100%, 50%"
      })

      shopping = @current_user.categories.create({
        name: "Shopping",
        symbol: "shopping-bag",
        color: "252, 100%, 50%"
      })

      transport = @current_user.categories.create({
        name: "Transport",
        symbol: "shuttle-van",
        color: "288, 100%, 50%"
      })

      vehicle = @current_user.categories.create({
        name: "Vehicle",
        symbol: "cog",
        color: "324, 100%, 50%"
      })

      @current_user.categories.create([
        {
          name: "Cinema",
          symbol: "film",
          parent_id: entertainment.id,
          color: entertainment.color
        },
        {
          name: "Date",
          symbol: "heart",
          parent_id: entertainment.id,
          color: entertainment.color
        },
        {
          name: "Hobbies",
          symbol: "palette",
          parent_id: entertainment.id,
          color: entertainment.color
        },
        {
          name: "Holiday",
          symbol: "suitcase-rolling",
          parent_id: entertainment.id,
          color: entertainment.color
        },
        {
          name: "Lottery / Gambling",
          symbol: "ticket-alt",
          parent_id: entertainment.id,
          color: entertainment.color
        },
        {
          name: "Social",
          symbol: "user-friends",
          parent_id: entertainment.id,
          color: entertainment.color
        },
        {
          name: "Software",
          symbol: "code",
          parent_id: entertainment.id,
          color: entertainment.color
        },
        {
          name: "Sport Events",
          symbol: "football-ball",
          parent_id: entertainment.id,
          color: entertainment.color
        },
        {
          name: "Subscriptions",
          symbol: "money-bill-wave-alt",
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
          symbol: "gamepad",
          parent_id: entertainment.id,
          color: entertainment.color
        },
        {
          name: "Bars / Pubs",
          symbol: "glass-cheers",
          parent_id: food_drinks.id,
          color: food_drinks.color
        },
        {
          name: "Fast Food",
          symbol: "hamburger",
          parent_id: food_drinks.id,
          color: food_drinks.color
        },
        {
          name: "Groceries",
          symbol: "shopping-basket",
          parent_id: food_drinks.id,
          color: food_drinks.color
        },
        {
          name: "Order / Take-out",
          symbol: "pizza-slice",
          parent_id: food_drinks.id,
          color: food_drinks.color
        },
        {
          name: "Restaurant",
          symbol: "concierge-bell",
          parent_id: food_drinks.id,
          color: food_drinks.color
        },
        {
          name: "Dentist",
          symbol: "tooth",
          parent_id: health.id,
          color: health.color
        },
        {
          name: "Doctor",
          symbol: "stethoscope",
          parent_id: health.id,
          color: health.color
        },
        {
          name: "Insurance",
          symbol: "file-medical",
          parent_id: health.id,
          color: health.color
        },
        {
          name: "Pharmacy",
          symbol: "pills",
          parent_id: health.id,
          color: health.color
        },
        {
          name: "Psychiatrist",
          symbol: "brain",
          parent_id: health.id,
          color: health.color
        },
        {
          name: "Sport & Fitness",
          symbol: "dumbbell",
          parent_id: health.id,
          color: health.color
        },
        {
          name: "Wellness & Beauty",
          symbol: "spa",
          parent_id: health.id,
          color: health.color
        },
        {
          name: "Electricity",
          symbol: "bolt",
          parent_id: household.id,
          color: household.color
        },
        {
          name: "Insurance",
          symbol: "house-damage",
          parent_id: household.id,
          color: household.color
        },
        {
          name: "Internet",
          symbol: "wifi",
          parent_id: household.id,
          color: household.color
        },
        {
          name: "Maintenance",
          symbol: "brush",
          parent_id: household.id,
          color: household.color
        },
        {
          name: "Mortgage",
          symbol: "percentage",
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
          symbol: "key",
          parent_id: household.id,
          color: household.color
        },
        {
          name: "Services",
          symbol: "hands-helping",
          parent_id: household.id,
          color: household.color
        },
        {
          name: "Water",
          symbol: "tint",
          parent_id: household.id,
          color: household.color
        },
        {
          name: "Child Support",
          symbol: "baby",
          parent_id: income.id,
          color: income.color
        },
        {
          name: "Gifts",
          symbol: "gift",
          parent_id: income.id,
          color: income.color
        },
        {
          name: "Interest / Dividends",
          symbol: "percentage",
          parent_id: income.id,
          color: income.color
        },
        {
          name: "Lending",
          symbol: "book",
          parent_id: income.id,
          color: income.color
        },
        {
          name: "Lottery / Gambling",
          symbol: "ticket-alt",
          parent_id: income.id,
          color: income.color
        },
        {
          name: "Refunds",
          symbol: "redo-alt",
          parent_id: income.id,
          color: income.color
        },
        {
          name: "Rent",
          symbol: "key",
          parent_id: income.id,
          color: income.color
        },
        {
          name: "Salary",
          symbol: "money-check-alt",
          parent_id: income.id,
          color: income.color
        },
        {
          name: "Sale",
          symbol: "cash-register",
          parent_id: income.id,
          color: income.color
        },
        {
          name: "Financial Investments",
          symbol: "chart-line",
          parent_id: investments.id,
          color: investments.color
        },
        {
          name: "Realty",
          symbol: "building",
          parent_id: investments.id,
          color: investments.color
        },
        {
          name: "Savings",
          symbol: "piggy-bank",
          parent_id: investments.id,
          color: investments.color
        },
        {
          name: "Alcohol",
          symbol: "wine-bottle",
          parent_id: other.id,
          color: other.color
        },
        {
          name: "Charges & Fees",
          symbol: "receipt",
          parent_id: other.id,
          color: other.color
        },
        {
          name: "E-cigarette",
          symbol: "smoking",
          parent_id: other.id,
          color: other.color
        },
        {
          name: "Fines",
          symbol: "bell",
          parent_id: other.id,
          color: other.color
        },
        {
          name: "Insurance",
          symbol: "umbrella",
          parent_id: other.id,
          color: other.color
        },
        {
          name: "Loans, Interest",
          symbol: "book",
          parent_id: other.id,
          color: other.color
        },
        {
          name: "Postal Services",
          symbol: "mail-bulk",
          parent_id: other.id,
          color: other.color
        },
        {
          name: "Tobacco",
          symbol: "smoking",
          parent_id: other.id,
          color: other.color
        },
        {
          name: "Books",
          symbol: "bookmark",
          parent_id: shopping.id,
          color: shopping.color
        },
        {
          name: "Clothes & Shoes",
          symbol: "tshirt",
          parent_id: shopping.id,
          color: shopping.color
        },
        {
          name: "Electronics",
          symbol: "plug",
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
          symbol: "puzzle-piece",
          parent_id: shopping.id,
          color: shopping.color
        },
        {
          name: "Home & Garden",
          symbol: "hammer",
          parent_id: shopping.id,
          color: shopping.color
        },
        {
          name: "Jewellery & Accessories",
          symbol: "ring",
          parent_id: shopping.id,
          color: shopping.color
        },
        {
          name: "Kids",
          symbol: "child",
          parent_id: shopping.id,
          color: shopping.color
        },
        {
          name: "Pets",
          symbol: "paw",
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
          symbol: "gamepad",
          parent_id: shopping.id,
          color: shopping.color
        },
        {
          name: "Flights",
          symbol: "plane-departure",
          parent_id: transport.id,
          color: transport.color
        },
        {
          name: "Public Transport",
          symbol: "train",
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
          symbol: "gas-pump",
          parent_id: vehicle.id,
          color: vehicle.color
        },
        {
          name: "Insurance",
          symbol: "car-crash",
          parent_id: vehicle.id,
          color: vehicle.color
        },
        {
          name: "Lease",
          symbol: "car",
          parent_id: vehicle.id,
          color: vehicle.color
        },
        {
          name: "Maintenance",
          symbol: "wrench",
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
          symbol: "key",
          parent_id: vehicle.id,
          color: vehicle.color
        }
      ])

    end

  end
end