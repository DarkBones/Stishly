module SettingsHelper
  def all_currencies(hash)
    array = []
    hash.each do |c|
      break if c[1][:iso_code] == 'XTS'

      array.push(["#{c[1][:iso_code]}", c[1][:iso_code]])
    end
    return array
  end
end
