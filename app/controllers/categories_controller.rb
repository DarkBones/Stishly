class CategoriesController < ApplicationController

	def index
	end

	def sort
		params[:category].each_with_index do |ids, idx|
			ids = ids.split(".")
			category = current_user.categories.friendly.find(ids[0])

			if ids[1] == "root"
				parent_id = nil
			else
				parent_id = current_user.categories.friendly.find(ids[1]).id
			end

			category.position = idx
			category.parent_id = parent_id

			category.save
		end
	end

	def update
		puts 1/0
	end

end
