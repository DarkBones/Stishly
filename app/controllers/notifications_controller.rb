class NotificationsController < ApplicationController

	def show
		@truncate = false
		@notifications = current_user.notifications.reverse_order.paginate(page: params[:page], per_page: APP_CONFIG['ui']['notifications']['page_length'])
	end

end
