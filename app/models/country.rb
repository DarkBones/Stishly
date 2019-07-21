# == Schema Information
#
# Table name: countries
#
#  id           :bigint           not null, primary key
#  name         :string(255)
#  date_format  :string(255)
#  week_start   :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  country_code :string(255)
#

class Country < ApplicationRecord
  has_many :users

  def self.get_dateformat(country_code)
    country = Country.where(country_code: country_code).first
    if country
      return country.date_format
    else
      return "dd mmm yyyy"
    end
  end

end
