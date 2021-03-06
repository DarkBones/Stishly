# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_10_27_162831) do

  create_table "account_histories", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "account_id"
    t.datetime "local_datetime"
    t.integer "balance"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_account_histories_on_account_id"
  end

  create_table "accounts", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "balance", default: 0
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name", null: false
    t.string "description"
    t.integer "position"
    t.string "currency", null: false
    t.boolean "is_default"
    t.string "account_type", default: "spend"
    t.string "hash_id"
    t.boolean "is_disabled", default: false
    t.string "slug"
    t.index ["name"], name: "index_accounts_on_name"
    t.index ["slug"], name: "index_accounts_on_slug"
    t.index ["user_id"], name: "index_accounts_on_user_id"
  end

  create_table "apis", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "budgets", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "category_id"
    t.integer "amount"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "hash_id"
    t.index ["category_id"], name: "index_budgets_on_category_id"
    t.index ["user_id"], name: "index_budgets_on_user_id"
  end

  create_table "categories", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", null: false
    t.string "color"
    t.string "symbol"
    t.bigint "user_id"
    t.bigint "parent_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "hash_id"
    t.integer "position"
    t.index ["parent_id"], name: "index_categories_on_parent_id"
    t.index ["user_id"], name: "index_categories_on_user_id"
  end

  create_table "countries", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.string "date_format"
    t.integer "week_start"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "country_code"
  end

  create_table "currencies", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.string "symbol"
    t.string "iso_code"
    t.integer "number_to_basic"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "currency_rate_updates", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "currency"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "currency_rates", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "from_currency"
    t.string "to_currency"
    t.float "rate"
    t.integer "used_count"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "daily_budgets", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "user_id"
    t.integer "spent"
    t.integer "amount"
    t.string "currency"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "local_date"
    t.index ["user_id"], name: "index_daily_budgets_on_user_id"
  end

  create_table "notifications", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "user_id"
    t.string "title"
    t.text "body"
    t.boolean "is_read", default: false
    t.timestamp "read_at"
    t.string "link"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "created_at_local_datetime"
    t.string "hash_id"
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "posts", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "title"
    t.text "body"
    t.string "thumbnail"
    t.date "published_on"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "slug"
    t.string "tags"
    t.boolean "is_featured"
    t.integer "position"
    t.index ["slug"], name: "index_posts_on_slug", unique: true
  end

  create_table "schedule_occurrences", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "schedule_id"
    t.datetime "occurrence_utc"
    t.datetime "occurrence_local"
    t.index ["schedule_id"], name: "index_schedule_occurrences_on_schedule_id"
  end

  create_table "schedules", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.bigint "user_id"
    t.date "start_date"
    t.date "end_date"
    t.string "period"
    t.integer "period_num", default: 0
    t.integer "days", default: 0
    t.string "days_month"
    t.integer "days_month_day"
    t.integer "days_exclude"
    t.string "exclusion_met"
    t.integer "exclusion_met_day"
    t.string "timezone"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_active", default: true
    t.date "next_occurrence"
    t.datetime "next_occurrence_utc"
    t.string "type_of", default: "schedule"
    t.date "pause_until"
    t.datetime "pause_until_utc"
    t.integer "current_period_id", default: 0
    t.string "hash_id"
    t.index ["name"], name: "index_schedules_on_name"
    t.index ["user_id"], name: "index_schedules_on_user_id"
  end

  create_table "schedules_transactions", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "schedule_id"
    t.bigint "transaction_id"
    t.index ["schedule_id"], name: "index_schedules_transactions_on_schedule_id"
    t.index ["transaction_id"], name: "index_schedules_transactions_on_transaction_id"
  end

  create_table "setting_values", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "entity_id"
    t.bigint "setting_id"
    t.string "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "entity_type"
    t.index ["entity_id"], name: "index_setting_values_on_entity_id"
    t.index ["setting_id"], name: "index_setting_values_on_setting_id"
  end

  create_table "settings", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "stripe_plans", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "currency"
    t.integer "price_eur"
    t.integer "price_month"
    t.integer "price_year"
    t.string "plan_id_month"
    t.string "plan_id_year"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "plan_id_month_no_trial"
    t.string "plan_id_year_no_trial"
    t.index ["currency"], name: "index_stripe_plans_on_currency"
  end

  create_table "transactions", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "user_id"
    t.integer "amount"
    t.integer "direction"
    t.string "description", limit: 100
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "account_id"
    t.string "timezone"
    t.string "currency"
    t.integer "account_currency_amount"
    t.bigint "category_id"
    t.bigint "parent_id"
    t.datetime "local_datetime"
    t.bigint "transfer_account_id"
    t.integer "user_currency_amount"
    t.integer "transfer_transaction_id"
    t.integer "scheduled_transaction_id"
    t.boolean "is_scheduled", default: false
    t.bigint "schedule_id"
    t.boolean "queue_scheduled", default: false
    t.boolean "is_queued", default: false
    t.integer "schedule_period_id"
    t.boolean "is_cancelled", default: false
    t.date "scheduled_date"
    t.boolean "is_balancer", default: false
    t.string "hash_id"
    t.boolean "is_main"
    t.index ["account_id"], name: "index_transactions_on_account_id"
    t.index ["category_id"], name: "index_transactions_on_category_id"
    t.index ["parent_id"], name: "index_transactions_on_parent_id"
    t.index ["schedule_id"], name: "index_transactions_on_schedule_id"
    t.index ["transfer_account_id"], name: "index_transactions_on_transfer_account_id"
    t.index ["user_id"], name: "index_transactions_on_user_id"
  end

  create_table "users", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.binary "first_name_enc"
    t.binary "last_name_enc"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.string "timezone", default: "Europe/London"
    t.string "country_code"
    t.bigint "country_id"
    t.string "currency", default: "USD"
    t.boolean "finished_setup", default: false
    t.string "encrypted_email"
    t.string "encrypted_email_iv"
    t.string "email_bidx"
    t.string "provider"
    t.string "uid"
    t.string "hash_id"
    t.string "subscription", default: "free"
    t.string "stripe_id"
    t.boolean "free_trial_eligable", default: true
    t.datetime "last_plan_check"
    t.boolean "is_admin", default: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["country_id"], name: "index_users_on_country_id"
    t.index ["email_bidx"], name: "index_users_on_email_bidx"
    t.index ["encrypted_email_iv"], name: "index_users_on_encrypted_email_iv", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
  end

  add_foreign_key "schedules", "users"
  add_foreign_key "transactions", "schedules"
end
