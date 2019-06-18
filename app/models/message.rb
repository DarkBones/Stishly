# == Schema Information
#
# Table name: messages
#
#  id         :bigint(8)        not null, primary key
#  user_id    :bigint(8)
#  title      :string(255)
#  body       :text(65535)
#  read       :boolean          default(FALSE)
#  read_at    :datetime
#  link       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Message < ApplicationRecord

	belongs_to :user

	def self.create_message(params, current_user, restrict_to_one_per_day)
		puts params["title"]

		tz = get_timezone(current_user)
		if restrict_to_one_per_day
			puts "message already created today" if messaged_today(current_user, params["title"], tz)
			return if messaged_today(current_user, params["title"], tz)
		end

		params[:created_at_local_datetime] = tz.utc_to_local(Time.now.utc)

		message = current_user.messages.new(params)
		message.save!

	end

private
	
	# returns true if an unread message with the same title has been issued today (local time)
	def self.messaged_today(current_user, title, tz)
		today = tz.utc_to_local(Time.now.utc).to_date

		message = current_user.messages.where("title = ? AND DATE(created_at_local_datetime) = DATE(?) AND is_read = FALSE", title, today)

		return message.length > 0
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
