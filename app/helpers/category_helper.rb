module CategoryHelper
  def draw_tree(node, result="")
    result += "<ul>"
    node.each do |n|
      result += "<li class=\"category_" + n[:id].to_s + "\">"
      result += image_tag('categories/' + n[:symbol] + '.svg', :class => 'rounded-circle', :style => 'background-color: hsl(' + n[:color] + ');', 'height' => '50')
      result += n[:name]
      result += "</li>"
      if n[:children].any?
        result += draw_tree(n[:children])
      end
    end

    result += "</ul>"

    return result.html_safe
  end
end
