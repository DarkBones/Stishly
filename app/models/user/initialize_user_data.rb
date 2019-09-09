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
        },
        {
          name: "Date",
          symbol: "heart",
          parent_id: entertainment.id,
        },
        {
          name: "Hobbies",
          symbol: "palette",
          parent_id: entertainment.id,
        },
        {
          name: "Holiday",
          symbol: "suitcase-rolling",
          parent_id: entertainment.id,
        },
        {
          name: "Lottery / Gambling",
          symbol: "ticket-alt",
          parent_id: entertainment.id,
        },
        {
          name: "Social",
          symbol: "user-friends",
          parent_id: entertainment.id,
        },
        {
          name: "Software",
          symbol: "code",
          parent_id: entertainment.id,
        },
        {
          name: "Sport Events",
          symbol: "football-ball",
          parent_id: entertainment.id,
        },
        {
          name: "Subscriptions",
          symbol: "money-bill-wave-alt",
          parent_id: entertainment.id,
        },
        {
          name: "TV",
          symbol: "tv",
          parent_id: entertainment.id,
        },
        {
          name: "Video Games",
          symbol: "gamepad",
          parent_id: entertainment.id,
        },
        {
          name: "Bars / Pubs",
          symbol: "glass-cheers",
          parent_id: food_drinks.id,
        },
        {
          name: "Fast Food",
          symbol: "hamburger",
          parent_id: food_drinks.id,
        },
        {
          name: "Groceries",
          symbol: "shopping-basket",
          parent_id: food_drinks.id,
        },
        {
          name: "Order / Take-out",
          symbol: "pizza-slice",
          parent_id: food_drinks.id,
        },
        {
          name: "Restaurant",
          symbol: "concierge-bell",
          parent_id: food_drinks.id,
        },
        {
          name: "Dentist",
          symbol: "tooth",
          parent_id: health.id,
        },
        {
          name: "Doctor",
          symbol: "stethoscope",
          parent_id: health.id,
        },
        {
          name: "Insurance",
          symbol: "file-medical",
          parent_id: health.id,
        },
        {
          name: "Pharmacy",
          symbol: "pills",
          parent_id: health.id,
        },
        {
          name: "Psychiatrist",
          symbol: "brain",
          parent_id: health.id,
        },
        {
          name: "Sport & Fitness",
          symbol: "dumbbell",
          parent_id: health.id,
        },
        {
          name: "Wellness & Beauty",
          symbol: "spa",
          parent_id: health.id,
        },
        {
          name: "Electricity",
          symbol: "bolt",
          parent_id: household.id,
        },
        {
          name: "Insurance",
          symbol: "house-damage",
          parent_id: household.id,
        },
        {
          name: "Internet",
          symbol: "wifi",
          parent_id: household.id,
        },
        {
          name: "Maintenance",
          symbol: "brush",
          parent_id: household.id,
        },
        {
          name: "Mortgage",
          symbol: "percentage",
          parent_id: household.id,
        },
        {
          name: "Phone",
          symbol: "phone",
          parent_id: household.id,
        },
        {
          name: "Rent",
          symbol: "key",
          parent_id: household.id,
        },
        {
          name: "Services",
          symbol: "hands-helping",
          parent_id: household.id,
        },
        {
          name: "Water",
          symbol: "tint",
          parent_id: household.id,
        },
        {
          name: "Child Support",
          symbol: "baby",
          parent_id: income.id,
        },
        {
          name: "Gifts",
          symbol: "gift",
          parent_id: income.id,
        },
        {
          name: "Interest / Dividends",
          symbol: "percentage",
          parent_id: income.id,
        },
        {
          name: "Lending",
          symbol: "book",
          parent_id: income.id,
        },
        {
          name: "Lottery / Gambling",
          symbol: "ticket-alt",
          parent_id: income.id,
        },
        {
          name: "Refunds",
          symbol: "redo-alt",
          parent_id: income.id,
        },
        {
          name: "Rent",
          symbol: "key",
          parent_id: income.id,
        },
        {
          name: "Salary",
          symbol: "money-check-alt",
          parent_id: income.id,
        },
        {
          name: "Sale",
          symbol: "cash-register",
          parent_id: income.id,
        },
        {
          name: "Financial Investments",
          symbol: "chart-line",
          parent_id: investments.id,
        },
        {
          name: "Realty",
          symbol: "building",
          parent_id: investments.id,
        },
        {
          name: "Savings",
          symbol: "piggy-bank",
          parent_id: investments.id,
        },
        {
          name: "Alcohol",
          symbol: "wine-bottle",
          parent_id: other.id,
        },
        {
          name: "Charges & Fees",
          symbol: "receipt",
          parent_id: other.id,
        },
        {
          name: "E-cigarette",
          symbol: "smoking",
          parent_id: other.id,
        },
        {
          name: "Fines",
          symbol: "bell",
          parent_id: other.id,
        },
        {
          name: "Insurance",
          symbol: "umbrella",
          parent_id: other.id,
        },
        {
          name: "Loans, Interest",
          symbol: "book",
          parent_id: other.id,
        },
        {
          name: "Postal Services",
          symbol: "mail-bulk",
          parent_id: other.id,
        },
        {
          name: "Tobacco",
          symbol: "smoking",
          parent_id: other.id,
        },
        {
          name: "Books",
          symbol: "bookmark",
          parent_id: shopping.id,
        },
        {
          name: "Clothes & Shoes",
          symbol: "tshirt",
          parent_id: shopping.id,
        },
        {
          name: "Electronics",
          symbol: "plug",
          parent_id: shopping.id,
        },
        {
          name: "Gifts",
          symbol: "gifts",
          parent_id: shopping.id,
        },
        {
          name: "Hobbies",
          symbol: "puzzle-piece",
          parent_id: shopping.id,
        },
        {
          name: "Home & Garden",
          symbol: "hammer",
          parent_id: shopping.id,
        },
        {
          name: "Jewellery & Accessories",
          symbol: "ring",
          parent_id: shopping.id,
        },
        {
          name: "Kids",
          symbol: "child",
          parent_id: shopping.id,
        },
        {
          name: "Pets",
          symbol: "paw",
          parent_id: shopping.id,
        },
        {
          name: "Tools",
          symbol: "tools",
          parent_id: shopping.id,
        },
        {
          name: "Video Games",
          symbol: "gamepad",
          parent_id: shopping.id,
        },
        {
          name: "Flights",
          symbol: "plane-departure",
          parent_id: transport.id,
        },
        {
          name: "Public Transport",
          symbol: "train",
          parent_id: transport.id,
        },
        {
          name: "Taxi",
          symbol: "taxi",
          parent_id: transport.id,
        },
        {
          name: "Fuel",
          symbol: "gas-pump",
          parent_id: vehicle.id,
        },
        {
          name: "Insurance",
          symbol: "car-crash",
          parent_id: vehicle.id,
        },
        {
          name: "Lease",
          symbol: "car",
          parent_id: vehicle.id,
        },
        {
          name: "Maintenance",
          symbol: "wrench",
          parent_id: vehicle.id,
        },
        {
          name: "Parking",
          symbol: "parking",
          parent_id: vehicle.id,
        },
        {
          name: "Rental",
          symbol: "key",
          parent_id: vehicle.id,
        }
      ])

    end

  end
end