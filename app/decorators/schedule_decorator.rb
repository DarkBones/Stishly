class ScheduleDecorator < ApplicationDecorator
  delegate_all

  def time_num
    return model.next_occurrence.strftime("%Y%m%d").to_i
  end

end
