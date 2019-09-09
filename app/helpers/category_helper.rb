module CategoryHelper

  def draw_tree(node, suff="")
    result = "<ul>"
    node.each do |n|
      result += "<li class=\"category_" + n[:id].to_s + " dropdown-item py-2 px-0\""
      result += " path=\"#{n[:children_paths]}\""
      result += " onclick=\"setCategory(this, '" + n[:id].to_s + "', '" + suff + "')\">"
      #result += image_tag('categories/' + n[:symbol] + '.svg', :class => 'rounded-circle', :style => 'background-color: hsl(' + n[:color] + ');', 'height' => '30')
      result += fa_icon n[:symbol], class: "rounded-circle", :style => 'background-color: hsl(' + n[:color] + '); color: white; padding: 5px;'
      result += " " + n[:name]
      result += "</li>"
      if n[:children].any?
        result += draw_tree(n[:children], suff)
      end
    end

    result += "</ul>"

    return result.html_safe
  end
end
