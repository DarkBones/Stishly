class ChartDatum < ApplicationRecord

	def self.account_history(account, start_date: nil, end_date: nil, days: 30)
  	start_date ||= days.days.ago.to_date
  	end_date ||= Time.now.to_date

  	end_date += 1.day

  	currency = Money::Currency.new(account.currency)

  	data = {}
  	account.account_histories.where("local_datetime >= ? AND local_datetime <= ?", start_date, end_date).order(:local_datetime).reverse_order().each do |h|
  		data[h.local_datetime.strftime("%d-%b-%Y")] = (h.balance.to_f / currency.subunit_to_unit) unless data.keys.include? h.local_datetime.strftime("%d-%b-%Y")
  	end

  	return data
  end

  def self.user_history(user, start_date: nil, end_date: nil, days: 30)
  	start_date ||= days.days.ago.to_date
  	end_date ||= Time.now.to_date

  	end_date += 1.day

  	data = []
  	user.accounts.each do |a|
  		
  		d = {
  			name: a.name,
  			data: {}
  		}

  		currency_account = Money::Currency.new(a.currency)
  		currency_user = Money::Currency.new(user.currency)

  		a.account_histories.where("local_datetime >= ? AND local_datetime <= ?", start_date, end_date).order(:local_datetime).reverse_order().each do |h|
  			unless d[:data].keys.include? h.local_datetime.strftime("%d-%b-%Y")
  				balance = h.balance

  				if a.currency != user.currency
  					balance = CurrencyRate.convert(balance, currency_account, currency_user)
  				end

  				balance = balance.to_f / currency_user.subunit_to_unit

  				d[:data][h.local_datetime.strftime("%d-%b-%Y")] = balance

  			end
  		end

  		data.push(d)

  	end

  	return data

  end

  def self.account_categories(account, start_date: nil, end_date: nil, days: 30, type: "expense")
    start_date ||= days.days.ago.to_date
    end_date ||= Time.now.to_date

    end_date += 1.day

    if type == "expense"
      transactions = account.transactions.where("local_datetime >= ? AND local_datetime <= ? AND parent_id is null AND amount < 0", start_date, end_date)
    else
      transactions = account.transactions.where("local_datetime >= ? AND local_datetime <= ? AND parent_id is null AND amount > 0", start_date, end_date)
    end

    currency = Money::Currency.new(account.currency)

    categories = get_category_charts(transactions, currency, type: "account")
  end

  def self.user_categories(user, start_date: nil, end_date: nil, days: 30, type: "expense")
    start_date ||= days.days.ago.to_date
    end_date ||= Time.now.to_date

    end_date += 1.day

    if type == "expense"
      transactions = user.transactions.where("local_datetime >= ? AND local_datetime <= ? AND parent_id is null AND amount < 0", start_date, end_date)
    else
      transactions = user.transactions.where("local_datetime >= ? AND local_datetime <= ? AND parent_id is null AND amount > 0", start_date, end_date)
    end

    currency = Money::Currency.new(user.currency)

    categories = get_category_charts(transactions, currency, type: "user")
  end

private

  def self.get_category_charts(transactions, currency, type: "account")
    categorized_transactions = transactions.where("category_id IS NOT NULL AND category_id > 0")
    uncategorized_transactions = transactions.where("category_id IS NULL OR category_id = 0")

    categories = {}
    totals = {}
    root = {}
    root_colors = []
    total = 0
    
    # iterate over the unique category ids
    categorized_transactions.distinct.pluck(:category_id).each do |cat_id|
      # find the category object
      category = Category.find(cat_id).decorate

      # store the total amount of transactions with the same category id
      amount = categorized_transactions.where(category_id: cat_id).sum(:amount)
      if type == "account"
        amount = categorized_transactions.where(category_id: cat_id).sum(:account_currency_amount).to_f.abs
      else
        amount = categorized_transactions.where(category_id: cat_id).sum(:user_currency_amount).to_f.abs
      end
      total += amount
      amount /= currency.subunit_to_unit

      # find the parent id
      parent_id = category.parent_id
      # while there are parents, create a new chart
      until parent_id.nil?
        parent = Category.find(parent_id).decorate

        unless categories.keys.include? parent.name
          categories[parent.name] = {}
          totals[parent.name] = 0
        end

        unless categories[parent.name].keys.include? category.name
          categories[parent.name][category.name] = 0
        end

        categories[parent.name][category.name] += amount
        totals[parent.name] += amount

        category = parent

        parent_id = parent.parent_id

        # create the root chart
        if parent_id.nil?

          unless root.keys.include? category.name
            root[category.name] = 0
            root_colors.push(category.color)
          end

          root[category.name] += amount
        end

      end

    end

    # insert the uncategorized transactions in root
    uncategorized_transactions.each do |transaction|
      unless transaction.transfer_transaction.nil?
        if type == "account" && transaction.account.hash_id != transaction.transfer_transaction.account.hash_id
          unless root.keys.include? I18n.t('categories.transferred')
            root[I18n.t('categories.transferred')] = 0
            root_colors.push("#FFC107")
          end

          amount = transaction.account_currency_amount.to_f
          total += amount
          amount /= currency.subunit_to_unit
          root[I18n.t('categories.transferred')] += amount
        end

      else

        unless root.keys.include? I18n.t('categories.uncategorized')
          root[I18n.t('categories.uncategorized')] = 0
          root_colors.push("#808080")
        end

        if type == "account"
          amount = transaction.account_currency_amount
        else
          amount = transaction.user_currency_amount
        end
        total += amount

        amount /= currency.subunit_to_unit

        root[I18n.t('categories.uncategorized')] += amount

      end
    end

    # sort the hash by amount
    totals = totals.sort_by {|_key, value| value}.reverse

    puts categories.to_yaml

    return {
      total: total,
      currency: currency.iso_code,
      root: root,
      root_colors: root_colors,
      totals: totals,
      charts: categories
    }

  end

end
