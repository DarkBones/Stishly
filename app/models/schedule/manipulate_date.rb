class Schedule
  class ManipulateDate

    def initialize(params)
      @schedule = params[:schedule]
      @reverse = params[:reverse] || false

      ignore_timezone = params[:ignore_timezone] || false
      @ignore_expired = params[:ignore_expired] || false
      @return_datetime = params[:return_datetime] || false

      # set the timezone to that of the schedule
      tz = TZInfo::Timezone.get(@schedule.timezone)

      @date = params[:date]
      @date ||= tz.utc_to_local(Time.now).to_date
      @date = tz.utc_to_local(Time.now).to_date if @date < Time.now.to_date && !ignore_timezone
    end

    

  end
end