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
        color: "#FBD237",
        position: 1
      })

      food_drinks = @current_user.categories.create({
        name: "Food & Drinks",
        symbol: "utensils",
        color: "#F4CDC3",
        position: 13
      })

      health = @current_user.categories.create({
        name: "Health",
        symbol: "heartbeat",
        color: "#D7AE91",
        position: 19
      })

      household = @current_user.categories.create({
        name: "Household",
        symbol: "home",
        color: "#86D7E1",
        position: 27
      })

      income = @current_user.categories.create({
        name: "Income",
        symbol: "coins",
        color: "#7CB436",
        position: 37
      })

      investments = @current_user.categories.create({
        name: "investments",
        symbol: "file-invoice-dollar",
        color: "#FF470E",
        position: 47
      })

      other = @current_user.categories.create({
        name: "Other",
        symbol: "ellipsis-h",
        color: "#E30677",
        position: 51
      })

      shopping = @current_user.categories.create({
        name: "Shopping",
        symbol: "shopping-bag",
        color: "#4588A5",
        position: 60
      })

      transport = @current_user.categories.create({
        name: "Transport",
        symbol: "shuttle-van",
        color: "#567243",
        position: 72
      })

      vehicle = @current_user.categories.create({
        name: "Vehicle",
        symbol: "cog",
        color: "#004C8F",
        position: 76
      })

      @current_user.categories.create([
        {
          name: "Cinema",
          symbol: "film",
          parent_id: entertainment.id,
          position: 2
        },
        {
          name: "Date",
          symbol: "heart",
          parent_id: entertainment.id,
          position: 3
        },
        {
          name: "Hobbies",
          symbol: "palette",
          parent_id: entertainment.id,
          position: 4
        },
        {
          name: "Holiday",
          symbol: "suitcase-rolling",
          parent_id: entertainment.id,
          position: 5
        },
        {
          name: "Lottery / Gambling",
          symbol: "ticket-alt",
          parent_id: entertainment.id,
          position: 6
        },
        {
          name: "Social",
          symbol: "user-friends",
          parent_id: entertainment.id,
          position: 7
        },
        {
          name: "Software",
          symbol: "code",
          parent_id: entertainment.id,
          position: 8
        },
        {
          name: "Sport Events",
          symbol: "football-ball",
          parent_id: entertainment.id,
          position: 9
        },
        {
          name: "Subscriptions",
          symbol: "money-bill-wave-alt",
          parent_id: entertainment.id,
          position: 10
        },
        {
          name: "TV",
          symbol: "tv",
          parent_id: entertainment.id,
          position: 11
        },
        {
          name: "Video Games",
          symbol: "gamepad",
          parent_id: entertainment.id,
          position: 12
        },
        {
          name: "Bars / Pubs",
          symbol: "glass-cheers",
          parent_id: food_drinks.id,
          position: 14
        },
        {
          name: "Fast Food",
          symbol: "hamburger",
          parent_id: food_drinks.id,
          position: 15
        },
        {
          name: "Groceries",
          symbol: "shopping-basket",
          parent_id: food_drinks.id,
          position: 16
        },
        {
          name: "Order / Take-out",
          symbol: "pizza-slice",
          parent_id: food_drinks.id,
          position: 17
        },
        {
          name: "Restaurant",
          symbol: "concierge-bell",
          parent_id: food_drinks.id,
          position: 18
        },
        {
          name: "Dentist",
          symbol: "tooth",
          parent_id: health.id,
          position: 20
        },
        {
          name: "Doctor",
          symbol: "stethoscope",
          parent_id: health.id,
          position: 21
        },
        {
          name: "Insurance",
          symbol: "file-medical",
          parent_id: health.id,
          position: 22
        },
        {
          name: "Pharmacy",
          symbol: "pills",
          parent_id: health.id,
          position: 23
        },
        {
          name: "Psychiatrist",
          symbol: "brain",
          parent_id: health.id,
          position: 24
        },
        {
          name: "Sport & Fitness",
          symbol: "dumbbell",
          parent_id: health.id,
          position: 25
        },
        {
          name: "Wellness & Beauty",
          symbol: "spa",
          parent_id: health.id,
          position: 26
        },
        {
          name: "Electricity",
          symbol: "bolt",
          parent_id: household.id,
          position: 28
        },
        {
          name: "Insurance",
          symbol: "house-damage",
          parent_id: household.id,
          position: 29
        },
        {
          name: "Internet",
          symbol: "wifi",
          parent_id: household.id,
          position: 30
        },
        {
          name: "Maintenance",
          symbol: "brush",
          parent_id: household.id,
          position: 31
        },
        {
          name: "Mortgage",
          symbol: "percentage",
          parent_id: household.id,
          position: 32
        },
        {
          name: "Phone",
          symbol: "phone",
          parent_id: household.id,
          position: 33
        },
        {
          name: "Rent",
          symbol: "key",
          parent_id: household.id,
          position: 34
        },
        {
          name: "Services",
          symbol: "hands-helping",
          parent_id: household.id,
          position: 35
        },
        {
          name: "Water",
          symbol: "tint",
          parent_id: household.id,
          position: 36
        },
        {
          name: "Child Support",
          symbol: "baby",
          parent_id: income.id,
          position: 38
        },
        {
          name: "Gifts",
          symbol: "gift",
          parent_id: income.id,
          position: 39
        },
        {
          name: "Interest / Dividends",
          symbol: "percentage",
          parent_id: income.id,
          position: 40
        },
        {
          name: "Lending",
          symbol: "book",
          parent_id: income.id,
          position: 41
        },
        {
          name: "Lottery / Gambling",
          symbol: "ticket-alt",
          parent_id: income.id,
          position: 42
        },
        {
          name: "Refunds",
          symbol: "redo-alt",
          parent_id: income.id,
          position: 43
        },
        {
          name: "Rent",
          symbol: "key",
          parent_id: income.id,
          position: 44
        },
        {
          name: "Salary",
          symbol: "money-check-alt",
          parent_id: income.id,
          position: 45
        },
        {
          name: "Sale",
          symbol: "cash-register",
          parent_id: income.id,
          position: 46
        },
        {
          name: "Financial Investments",
          symbol: "chart-line",
          parent_id: investments.id,
          position: 48
        },
        {
          name: "Realty",
          symbol: "building",
          parent_id: investments.id,
          position: 49
        },
        {
          name: "Savings",
          symbol: "piggy-bank",
          parent_id: investments.id,
          position: 50
        },
        {
          name: "Alcohol",
          symbol: "wine-bottle",
          parent_id: other.id,
          position: 52
        },
        {
          name: "Charges & Fees",
          symbol: "receipt",
          parent_id: other.id,
          position: 53
        },
        {
          name: "E-cigarette",
          symbol: "smoking",
          parent_id: other.id,
          position: 54
        },
        {
          name: "Fines",
          symbol: "bell",
          parent_id: other.id,
          position: 55
        },
        {
          name: "Insurance",
          symbol: "umbrella",
          parent_id: other.id,
          position: 56
        },
        {
          name: "Loans, Interest",
          symbol: "book",
          parent_id: other.id,
          position: 57
        },
        {
          name: "Postal Services",
          symbol: "mail-bulk",
          parent_id: other.id,
          position: 58
        },
        {
          name: "Tobacco",
          symbol: "smoking",
          parent_id: other.id,
          position: 59
        },
        {
          name: "Books",
          symbol: "bookmark",
          parent_id: shopping.id,
          position: 61
        },
        {
          name: "Clothes & Shoes",
          symbol: "tshirt",
          parent_id: shopping.id,
          position: 62
        },
        {
          name: "Electronics",
          symbol: "plug",
          parent_id: shopping.id,
          position: 63
        },
        {
          name: "Gifts",
          symbol: "gifts",
          parent_id: shopping.id,
          position: 64
        },
        {
          name: "Hobbies",
          symbol: "puzzle-piece",
          parent_id: shopping.id,
          position: 65
        },
        {
          name: "Home & Garden",
          symbol: "hammer",
          parent_id: shopping.id,
          position: 66
        },
        {
          name: "Jewellery & Accessories",
          symbol: "ring",
          parent_id: shopping.id,
          position: 67
        },
        {
          name: "Kids",
          symbol: "child",
          parent_id: shopping.id,
          position: 68
        },
        {
          name: "Pets",
          symbol: "paw",
          parent_id: shopping.id,
          position: 69
        },
        {
          name: "Tools",
          symbol: "tools",
          parent_id: shopping.id,
          position: 70
        },
        {
          name: "Video Games",
          symbol: "gamepad",
          parent_id: shopping.id,
          position: 71
        },
        {
          name: "Flights",
          symbol: "plane-departure",
          parent_id: transport.id,
          position: 73
        },
        {
          name: "Public Transport",
          symbol: "train",
          parent_id: transport.id,
          position: 74
        },
        {
          name: "Taxi",
          symbol: "taxi",
          parent_id: transport.id,
          position: 75
        },
        {
          name: "Fuel",
          symbol: "gas-pump",
          parent_id: vehicle.id,
          position: 77
        },
        {
          name: "Insurance",
          symbol: "car-crash",
          parent_id: vehicle.id,
          position: 78
        },
        {
          name: "Lease",
          symbol: "car",
          parent_id: vehicle.id,
          position: 79
        },
        {
          name: "Maintenance",
          symbol: "wrench",
          parent_id: vehicle.id,
          position: 80
        },
        {
          name: "Parking",
          symbol: "parking",
          parent_id: vehicle.id,
          position: 81
        },
        {
          name: "Rental",
          symbol: "key",
          parent_id: vehicle.id,
          position: 82
        }
      ])

    end

  end
end