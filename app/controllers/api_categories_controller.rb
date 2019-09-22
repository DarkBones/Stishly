class ApiCategoriesController < ApplicationController

	def transaction_count
		category = current_user.categories.friendly.find(params[:id])
		render plain: category.transactions.length
	end

	def delete
		category = current_user.categories.friendly.find(params[:id])
		
		Category.delete(category)
	end

end
