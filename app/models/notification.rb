# == Schema Information
#
# Table name: notifications
#
#  id                        :bigint           not null, primary key
#  user_id                   :bigint
#  title                     :string(255)
#  body                      :text(65535)
#  is_read                   :boolean          default(FALSE)
#  read_at                   :datetime
#  link                      :string(255)
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  created_at_local_datetime :datetime
#  hash_id                   :string(255)
#

class Notification < ApplicationRecord
	include Friendlyable

	belongs_to :user

	def self.create(params, current_user, restrict_to_one_per_day)
		tz = get_timezone(current_user)
		if restrict_to_one_per_day
			return if notified_today(current_user, params["title"], tz)
		end

		params[:created_at_local_datetime] = tz.utc_to_local(Time.now.utc)

		notification = current_user.notifications.new(params)
		notification.save!

	end

private
	
	# returns true if an unread message with the same title has been issued today (local time)
	def self.notified_today(current_user, title, tz)
		today = tz.utc_to_local(Time.now.utc).to_date

		notification = current_user.notifications.where("title = ? AND DATE(created_at_local_datetime) = DATE(?) AND is_read = FALSE", title, today)

		return notification.length > 0
	end

	def self.get_timezone(current_user)
		begin
			tz = TZInfo::Timezone.get(current_user.timezone)
		rescue
			tz = TZInfo::Timezone.get("Europe/London")
		end

		return tz
	end

	def self.get_local_datetime(tz)
		return tz.utc_to_local(Time.now.utc)
	end

end
