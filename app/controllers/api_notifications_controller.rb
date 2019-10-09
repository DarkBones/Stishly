class ApiNotificationsController < BaseApiController

	def mark_read
		@user.notifications.where(is_read: false).each do |n|
			n.is_read = true
			n.read_at = Time.now.utc
			n.save
		end
	end

end
