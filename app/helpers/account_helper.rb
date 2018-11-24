module AccountHelper
  def balance(b, cents, span_class="")
    cents > 0 ? decimals = Math.log10(cents).ceil : decimals = 0

    b = b.to_f
    b /= cents if cents > 0
    b_main = b.to_i
    b_cents = ((b - b_main) * cents).round.to_i.abs.to_s

    while b_cents.length < decimals
      b_cents += "0"
    end

    result = b_main.to_s
    if cents > 0
      result += ".<span"
      result += " class=\"#{span_class}\"" if span_class != ""
      result += ">#{b_cents}</span>"
    end
    #result += ".<span>#{b_cents}</span>" if cents > 0
    return result.html_safe
  end
  
end
