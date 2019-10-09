class NotificationDecorator < ApplicationDecorator
  delegate_all

  def short_time
  	tz = TZInfo::Timezone.get(model.user.timezone)

  	if tz.utc_to_local(model.created_at).to_date == tz.utc_to_local(Time.now.utc).to_date
  		return tz.utc_to_local(model.created_at).strftime("%H:%M")
  	else
  		return tz.utc_to_local(model.created_at).strftime("%d/%m")
  	end
  end

end
