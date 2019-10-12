# == Schema Information
#
# Table name: daily_budgets
#
#  id         :bigint           not null, primary key
#  user_id    :bigint
#  spent      :integer
#  amount     :integer
#  currency   :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class DailyBudget < ApplicationRecord

	def self.get_daily_budget(user)
		budget = self.get_from_cache(user)

		return budget unless budget.nil?
		
		budget = CalculateDailyBudget.new(user).perform
		self.store_cache(user, budget)
		self.store_db(budget, user)

		return budget
	end

	def self.recalculate(user)
		self.invalidate_cache(user)

		budget = CalculateDailyBudget.new(user).perform
		self.store_cache(user, budget)
		self.store_db(budget, user)

		return budget
	end

	def self.invalidate_cache(user)
		cache = Rails.cache
		cache_name = user.hash_id + '_daily_budget'

		if cache.exist?(cache_name)
			cache.delete(cache_name)
		end
	end

	def self.recalculate_all
		User.all.each do |user|
			tz = TZInfo::Timezone.get(user.timezone)

			hour = tz.utc_to_local(Time.now.utc).strftime("%H").to_i
			if hour == 0
				current_sign_in_at = user.current_sign_in_at

				if !current_sign_in_at.nil? && current_sign_in_at >= 30.days.ago
					self.recalculate(user)
				else
					self.invalidate_cache(user)
				end

			end
		end
	end

private

	def self.store_db(budget, user)
		if budget[:type] == 'daily_budget'
			
			tz = TZInfo::Timezone.get(user.timezone)
			local_date = tz.utc_to_local(Time.now.utc).to_date

			db = DailyBudget.where(user_id: user.id, local_date: local_date).take
			db = DailyBudget.new if db.nil?

			db.user_id = user.id
			db.spent = budget[:spent][:today]
			db.amount = budget[:budget][:today]
			db.currency = user.currency
			db.local_date = local_date
			db.save

		end
	end

	def self.get_from_cache(user)
		cache = Rails.cache

		cache_name = user.hash_id + '_daily_budget'

		if cache.exist?(cache_name)
			return cache.fetch(cache_name)
		else
			return nil
		end
	end

	def self.store_cache(user, budget)
		invalidate_cache(user)

		cache = Rails.cache
		cache_name = user.hash_id + '_daily_budget'
		cache.write(cache_name, budget)
	end

end
