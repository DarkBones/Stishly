module ApplicationHelper
  def balance(b, currency, span_class="", id="")
    Money.locale_backend = :i18n
    
    balance = Money.new(b, currency.iso_code).format
    balance.sub! currency.symbol, currency.symbol + " "
    balance = balance.split(".")

    result = balance[0]

    if balance[1]
      result += ".<span"
      result += " class=\"#{span_class}\"" if span_class != ""
      result += " id=\"#{id}\"" if id != ""
      result += ">#{balance[1]}</span>"
    end

    return result.html_safe
  end
end
