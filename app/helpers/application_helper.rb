module ApplicationHelper
  
  def markdown(text)
    require 'redcarpet'
    markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML)
    return markdown.render(text).html_safe
  end

  def balance(b, currency, span_class="", id="")
    if currency.class == String
      currency = Money::Currency.new(currency)
    end
    
    Money.locale_backend = :i18n

    balance = Money.new(b, currency.iso_code).format

    balance = balance.split(".")

    if balance.length > 1
      result = balance[0...-1][0]
    else
      result = balance[0]
    end

    if balance[1] && span_class != "none"
      if span_class.length > 0 || id.length > 0
        result += ".<span"
        result += " class=\"#{span_class}\"" unless span_class.length == 0
        result += " id=\"#{id}\"" unless id.length == 0
        result += ">#{balance[1]}</span>"
      else
        result += ".#{balance[1]}"
      end
    end

    return result.html_safe
  end

  def format_form_errors(obj, errors)
    result = "Failed to save #{obj}"
    result += "<ul class='list-unstyled'>"

    errors.each do |attribute, message|
      result += "<li>#{attribute}: #{message}</li>"
    end

    result += "</ul>"

    return result.html_safe.to_s
  end

  def hint(title, content, classSuff="")
    result = "<a tabindex=\"0\" role=\"button\" class=\"fa fa-question-circle clickable #{classSuff}\" data-toggle=\"popover\" data-trigger=\"focus\" data-placement=\"left\" "
    result += "title=\"#{title}\" "
    result += "data-content=\"#{content}\""
    result += "></a>"

    return result.html_safe.to_s
  end

end
