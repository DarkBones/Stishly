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
