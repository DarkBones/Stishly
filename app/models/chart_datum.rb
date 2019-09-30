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

  def self.account_categories(account, start_date: nil, end_date: nil, days: 30)
    start_date ||= days.days.ago.to_date
    end_date ||= Time.now.to_date

    end_date += 1.day

    transactions = account.transactions.where("local_datetime >= ? AND local_datetime <= ? AND parent_id is null AND amount < 0", start_date, end_date)

    currency = Money::Currency.new(account.currency)

    categories = get_category_charts(transactions, currency, type: "account")
  end

private

  def self.get_category_charts(transactions, currency, type: "account")
    categorized_transactions = transactions.where("category_id IS NOT NULL AND category_id > 0")
    uncategorized_transactions = transactions.where("category_id IS NULL OR category_id = 0")

    categories = {}
    totals = {}
    root = {}
    
    # iterate over the unique category ids
    categorized_transactions.distinct.pluck(:category_id).each do |cat_id|
      # find the category object
      category = Category.find(cat_id)

      # store the total amount of transactions with the same category id
      amount = categorized_transactions.where(category_id: cat_id).sum(:amount)
      if type == "account"
        amount = categorized_transactions.where(category_id: cat_id).sum(:account_currency_amount).to_f
      else
        amount = categorized_transactions.where(category_id: cat_id).sum(:user_currency_amount).to_f
      end
      amount /= currency.subunit_to_unit

      # find the parent id
      parent_id = category.parent_id
      # while there are parents, create a new chart
      until parent_id.nil?
        parent = Category.find(parent_id)

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
          unless categories.keys.include? :root
            categories[:root] = {}
            totals[:root] = 0
          end

          unless categories[:root].keys.include? category.name
            categories[:root][category.name] = 0
          end

          categories[:root][category.name] += amount
          totals[:root] += amount
        end

      end

    end

    # insert the uncategorized transactions in root
    uncategorized_transactions.each do |transaction|
      unless transaction.transfer_transaction.nil?
        if type == "account" && transaction.account.hash_id != transaction.transfer_transaction.account.hash_id
          unless categories[:root].keys.include? I18n.t('categories.transferred')
            categories[:root][I18n.t('categories.transferred')] = 0
          end

          amount = transaction.account_currency_amount.to_f / currency.subunit_to_unit
          categories[:root][I18n.t('categories.transferred')] += amount
          totals[:root] += amount
        end

      else

        unless categories[:root].keys.include? I18n.t('categories.uncategorized')
          categories[:root][I18n.t('categories.uncategorized')] = 0
        end

        if type == "account"
          amount = transaction.account_currency_amount
        else
          amount = transaction.user_currency_amount
        end

        amount /= currency.subunit_to_unit

        categories[:root][I18n.t('categories.uncategorized')] += amount
        totals[:root] += amount

      end
    end

    # sort the hash by amount
    totals = totals.sort_by {|_key, value| value}

    puts categories.to_yaml

    return {
      totals: totals,
      charts: categories
    }

  end

  def self.account_categories_OLD(account, start_date: nil, end_date: nil, days: 30)
  	start_date ||= days.days.ago.to_date
  	end_date ||= Time.now.to_date

  	end_date += 1.day

  	currency = Money::Currency.new(account.currency)

  	data = {}
  	account.transactions.where("local_datetime >= ? AND local_datetime <= ? AND parent_id is null", start_date, end_date).each do |t|

  		unless t.category_id.nil?
	  		if t.category_id > 0
	  			category_name = t.category.name
	  		elsif t.transfer_transaction.nil?
	  			category_name = "Uncategorized"
	  		else
	  			if t.amount > 0
	  				category_name = "Transferred to #{t.transfer_transaction.account.name}"
	  			else
	  				category_name = "Transferred from #{t.transfer_transaction.account.name}"
	  			end
	  		end
	  	else
	  		if t.transfer_transaction.nil?
	  			category_name = "Uncategorized"
	  		else
	  			if t.amount > 0
	  				category_name = "Transferred to #{t.transfer_transaction.account.name}"
	  			else
	  				category_name = "Transferred from #{t.transfer_transaction.account.name}"
	  			end
	  		end
	  	end

  		amount = t.account_currency_amount.to_f / currency.subunit_to_unit

  		if data.keys.include? category_name
  			data[category_name] += amount
  		else
  			data[category_name] = amount
  		end

  	end

  	return data

  end

end
