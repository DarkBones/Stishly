class Country < ApplicationRecord

  def self.get_dateformat(country_code)
    country = Country.where(country_code: country_code).first
    if country
      return country.date_format
    else
      return false
    end
  end

end
