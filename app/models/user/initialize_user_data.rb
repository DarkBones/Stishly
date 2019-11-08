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
        name: I18n.t("models.category.categories.entertainment.main"),
        symbol: "theater-masks",
        color: "#FBD237",
        position: 1
      })

      food_drinks = @current_user.categories.create({
        name: I18n.t("models.category.categories.food_drinks.main"),
        symbol: "utensils",
        color: "#F4CDC3",
        position: 13
      })

      health = @current_user.categories.create({
        name: I18n.t("models.category.categories.health.main"),
        symbol: "heartbeat",
        color: "#D7AE91",
        position: 19
      })

      household = @current_user.categories.create({
        name: I18n.t("models.category.categories.household.main"),
        symbol: "home",
        color: "#86D7E1",
        position: 27
      })

      income = @current_user.categories.create({
        name: I18n.t("models.category.categories.income.main"),
        symbol: "coins",
        color: "#7CB436",
        position: 37
      })

      investments = @current_user.categories.create({
        name: I18n.t("models.category.categories.investments.main"),
        symbol: "file-invoice-dollar",
        color: "#FF470E",
        position: 47
      })

      other = @current_user.categories.create({
        name: I18n.t("models.category.categories.other.main"),
        symbol: "ellipsis-h",
        color: "#E30677",
        position: 51
      })

      shopping = @current_user.categories.create({
        name: I18n.t("models.category.categories.shopping.main"),
        symbol: "shopping-bag",
        color: "#4588A5",
        position: 60
      })

      transport = @current_user.categories.create({
        name: I18n.t("models.category.categories.transport.main"),
        symbol: "shuttle-van",
        color: "#567243",
        position: 72
      })

      vehicle = @current_user.categories.create({
        name: I18n.t("models.category.categories.vehicle.main"),
        symbol: "cog",
        color: "#004C8F",
        position: 76
      })

      @current_user.categories.create([
        {
          name: I18n.t("models.category.categories.entertainment.cinema"),
          symbol: "film",
          parent_id: entertainment.id,
          position: 2
        },
        {
          name: I18n.t("models.category.categories.entertainment.date"),
          symbol: "heart",
          parent_id: entertainment.id,
          position: 3
        },
        {
          name: I18n.t("models.category.categories.entertainment.hobbies"),
          symbol: "palette",
          parent_id: entertainment.id,
          position: 4
        },
        {
          name: I18n.t("models.category.categories.entertainment.holiday"),
          symbol: "suitcase-rolling",
          parent_id: entertainment.id,
          position: 5
        },
        {
          name: I18n.t("models.category.categories.entertainment.lottery"),
          symbol: "ticket-alt",
          parent_id: entertainment.id,
          position: 6
        },
        {
          name: I18n.t("models.category.categories.entertainment.social"),
          symbol: "user-friends",
          parent_id: entertainment.id,
          position: 7
        },
        {
          name: I18n.t("models.category.categories.entertainment.software"),
          symbol: "code",
          parent_id: entertainment.id,
          position: 8
        },
        {
          name: I18n.t("models.category.categories.entertainment.sport_events"),
          symbol: "football-ball",
          parent_id: entertainment.id,
          position: 9
        },
        {
          name: I18n.t("models.category.categories.entertainment.subscriptions"),
          symbol: "money-bill-wave-alt",
          parent_id: entertainment.id,
          position: 10
        },
        {
          name: I18n.t("models.category.categories.entertainment.tv"),
          symbol: "tv",
          parent_id: entertainment.id,
          position: 11
        },
        {
          name: I18n.t("models.category.categories.entertainment.video_games"),
          symbol: "gamepad",
          parent_id: entertainment.id,
          position: 12
        },
        {
          name: I18n.t("models.category.categories.food_drinks.bars_pubs"),
          symbol: "glass-cheers",
          parent_id: food_drinks.id,
          position: 14
        },
        {
          name: I18n.t("models.category.categories.food_drinks.fast_food"),
          symbol: "hamburger",
          parent_id: food_drinks.id,
          position: 15
        },
        {
          name: I18n.t("models.category.categories.food_drinks.groceries"),
          symbol: "shopping-basket",
          parent_id: food_drinks.id,
          position: 16
        },
        {
          name: I18n.t("models.category.categories.food_drinks.order_takeout"),
          symbol: "pizza-slice",
          parent_id: food_drinks.id,
          position: 17
        },
        {
          name: I18n.t("models.category.categories.food_drinks.restaurant"),
          symbol: "concierge-bell",
          parent_id: food_drinks.id,
          position: 18
        },
        {
          name: I18n.t("models.category.categories.health.dentist"),
          symbol: "tooth",
          parent_id: health.id,
          position: 20
        },
        {
          name: I18n.t("models.category.categories.health.doctor"),
          symbol: "stethoscope",
          parent_id: health.id,
          position: 21
        },
        {
          name: I18n.t("models.category.categories.health.insurance"),
          symbol: "file-medical",
          parent_id: health.id,
          position: 22
        },
        {
          name: I18n.t("models.category.categories.health.pharmacy"),
          symbol: "pills",
          parent_id: health.id,
          position: 23
        },
        {
          name: I18n.t("models.category.categories.health.psychiatrist"),
          symbol: "brain",
          parent_id: health.id,
          position: 24
        },
        {
          name: I18n.t("models.category.categories.health.sport_fitness"),
          symbol: "dumbbell",
          parent_id: health.id,
          position: 25
        },
        {
          name: I18n.t("models.category.categories.health.wellness_beauty"),
          symbol: "spa",
          parent_id: health.id,
          position: 26
        },
        {
          name: I18n.t("models.category.categories.household.electricity"),
          symbol: "bolt",
          parent_id: household.id,
          position: 28
        },
        {
          name: I18n.t("models.category.categories.household.insurance"),
          symbol: "house-damage",
          parent_id: household.id,
          position: 29
        },
        {
          name: I18n.t("models.category.categories.household.internet"),
          symbol: "wifi",
          parent_id: household.id,
          position: 30
        },
        {
          name: I18n.t("models.category.categories.household.maintenance"),
          symbol: "brush",
          parent_id: household.id,
          position: 31
        },
        {
          name: I18n.t("models.category.categories.household.mortgage"),
          symbol: "percentage",
          parent_id: household.id,
          position: 32
        },
        {
          name: I18n.t("models.category.categories.household.phone"),
          symbol: "phone",
          parent_id: household.id,
          position: 33
        },
        {
          name: I18n.t("models.category.categories.household.rent"),
          symbol: "key",
          parent_id: household.id,
          position: 34
        },
        {
          name: I18n.t("models.category.categories.household.services"),
          symbol: "hands-helping",
          parent_id: household.id,
          position: 35
        },
        {
          name: I18n.t("models.category.categories.household.water"),
          symbol: "tint",
          parent_id: household.id,
          position: 36
        },
        {
          name: I18n.t("models.category.categories.income.child_support"),
          symbol: "baby",
          parent_id: income.id,
          position: 38
        },
        {
          name: I18n.t("models.category.categories.income.gifts"),
          symbol: "gift",
          parent_id: income.id,
          position: 39
        },
        {
          name: I18n.t("models.category.categories.income.interest"),
          symbol: "percentage",
          parent_id: income.id,
          position: 40
        },
        {
          name: I18n.t("models.category.categories.income.lending"),
          symbol: "book",
          parent_id: income.id,
          position: 41
        },
        {
          name: I18n.t("models.category.categories.income.lottery"),
          symbol: "ticket-alt",
          parent_id: income.id,
          position: 42
        },
        {
          name: I18n.t("models.category.categories.income.refunds"),
          symbol: "redo-alt",
          parent_id: income.id,
          position: 43
        },
        {
          name: I18n.t("models.category.categories.income.rent"),
          symbol: "key",
          parent_id: income.id,
          position: 44
        },
        {
          name: I18n.t("models.category.categories.income.salary"),
          symbol: "money-check-alt",
          parent_id: income.id,
          position: 45
        },
        {
          name: I18n.t("models.category.categories.income.sale"),
          symbol: "cash-register",
          parent_id: income.id,
          position: 46
        },
        {
          name: I18n.t("models.category.categories.investments.financial_investments"),
          symbol: "chart-line",
          parent_id: investments.id,
          position: 48
        },
        {
          name: I18n.t("models.category.categories.investments.realty"),
          symbol: "building",
          parent_id: investments.id,
          position: 49
        },
        {
          name: I18n.t("models.category.categories.investments.savings"),
          symbol: "piggy-bank",
          parent_id: investments.id,
          position: 50
        },
        {
          name: I18n.t("models.category.categories.other.alcohol"),
          symbol: "wine-bottle",
          parent_id: other.id,
          position: 52
        },
        {
          name: I18n.t("models.category.categories.other.charges_fees"),
          symbol: "receipt",
          parent_id: other.id,
          position: 53
        },
        {
          name: I18n.t("models.category.categories.other.e_cigarette"),
          symbol: "smoking",
          parent_id: other.id,
          position: 54
        },
        {
          name: I18n.t("models.category.categories.other.fines"),
          symbol: "bell",
          parent_id: other.id,
          position: 55
        },
        {
          name: I18n.t("models.category.categories.other.insurance"),
          symbol: "umbrella",
          parent_id: other.id,
          position: 56
        },
        {
          name: I18n.t("models.category.categories.other.loans_interest"),
          symbol: "book",
          parent_id: other.id,
          position: 57
        },
        {
          name: I18n.t("models.category.categories.other.postal"),
          symbol: "mail-bulk",
          parent_id: other.id,
          position: 58
        },
        {
          name: I18n.t("models.category.categories.other.tobacco"),
          symbol: "smoking",
          parent_id: other.id,
          position: 59
        },
        {
          name: I18n.t("models.category.categories.shopping.books"),
          symbol: "bookmark",
          parent_id: shopping.id,
          position: 61
        },
        {
          name: I18n.t("models.category.categories.shopping.clothes"),
          symbol: "tshirt",
          parent_id: shopping.id,
          position: 62
        },
        {
          name: I18n.t("models.category.categories.shopping.electronics"),
          symbol: "plug",
          parent_id: shopping.id,
          position: 63
        },
        {
          name: I18n.t("models.category.categories.shopping.gifts"),
          symbol: "gifts",
          parent_id: shopping.id,
          position: 64
        },
        {
          name: I18n.t("models.category.categories.shopping.hobbies"),
          symbol: "puzzle-piece",
          parent_id: shopping.id,
          position: 65
        },
        {
          name: I18n.t("models.category.categories.shopping.home_garden"),
          symbol: "hammer",
          parent_id: shopping.id,
          position: 66
        },
        {
          name: I18n.t("models.category.categories.shopping.jewellery"),
          symbol: "ring",
          parent_id: shopping.id,
          position: 67
        },
        {
          name: I18n.t("models.category.categories.shopping.kids"),
          symbol: "child",
          parent_id: shopping.id,
          position: 68
        },
        {
          name: I18n.t("models.category.categories.shopping.pets"),
          symbol: "paw",
          parent_id: shopping.id,
          position: 69
        },
        {
          name: I18n.t("models.category.categories.shopping.tools"),
          symbol: "tools",
          parent_id: shopping.id,
          position: 70
        },
        {
          name: I18n.t("models.category.categories.shopping.video_games"),
          symbol: "gamepad",
          parent_id: shopping.id,
          position: 71
        },
        {
          name: I18n.t("models.category.categories.transport.flights"),
          symbol: "plane-departure",
          parent_id: transport.id,
          position: 73
        },
        {
          name: I18n.t("models.category.categories.transport.public_transport"),
          symbol: "train",
          parent_id: transport.id,
          position: 74
        },
        {
          name: I18n.t("models.category.categories.transport.taxy"),
          symbol: "taxi",
          parent_id: transport.id,
          position: 75
        },
        {
          name: I18n.t("models.category.categories.vehicle.fuel"),
          symbol: "gas-pump",
          parent_id: vehicle.id,
          position: 77
        },
        {
          name: I18n.t("models.category.categories.vehicle.insurance"),
          symbol: "car-crash",
          parent_id: vehicle.id,
          position: 78
        },
        {
          name: I18n.t("models.category.categories.vehicle.lease"),
          symbol: "car",
          parent_id: vehicle.id,
          position: 79
        },
        {
          name: I18n.t("models.category.categories.vehicle.maintenance"),
          symbol: "wrench",
          parent_id: vehicle.id,
          position: 80
        },
        {
          name: I18n.t("models.category.categories.vehicle.parking"),
          symbol: "parking",
          parent_id: vehicle.id,
          position: 81
        },
        {
          name: I18n.t("models.category.categories.vehicle.rental"),
          symbol: "key",
          parent_id: vehicle.id,
          position: 82
        }
      ])

    end

  end
end