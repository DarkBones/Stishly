module CategoryHelper
  def draw_tree_OLD(node, result="")
    result += "<ul>"
    node.each do |n|
      result += "<li class=\"category_" + n[:id].to_s + " dropdown-item py-2 px-0\""
      result += " onclick=\"setCategory(" + n[:id].to_s + ")\">"
      result += image_tag('categories/' + n[:symbol] + '.svg', :class => 'rounded-circle', :style => 'background-color: hsl(' + n[:color] + ');', 'height' => '30')
      result += " " + n[:name]
      if n[:children].any?
        result += draw_tree(n[:children])
      end
      result += "</li>"
    end

    result += "</ul>"

    return result.html_safe
  end

  def draw_tree(node)
    result = "<ul>"
    node.each do |n|

      result += "<li class=\"category_" + n[:id].to_s + " dropdown-item py-2 px-0\""
      result += " path=\"#{n[:children_paths]}\""
      result += " onclick=\"setCategory(" + n[:id].to_s + ")\">"
      result += image_tag('categories/' + n[:symbol] + '.svg', :class => 'rounded-circle', :style => 'background-color: hsl(' + n[:color] + ');', 'height' => '30')
      result += " " + n[:name]
      result += "</li>"
      if n[:children].any?
        result += draw_tree(n[:children])
      end
    end

    result += "</ul>"

    return result.html_safe
  end
end
