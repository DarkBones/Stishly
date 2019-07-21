module TimezoneMethods
	def validate_timezone(tz)
    return tz if !tz.nil? && ActiveSupport::TimeZone[tz].present?
    return "Europe/London"
	end
end