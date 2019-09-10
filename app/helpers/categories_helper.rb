module CategoriesHelper

	def draw_tree(node, suff="", ul_class: "", include_sort_handle: false)
    result = "<ul class=\"#{ul_class}\">"
    node.each do |n|
      cl = "rounded-circle"
      cl += " category" unless n[:symbol].nil?
      result += "<li class=\"category_" + n[:id].to_s + " dropdown-item py-2 px-0\""
      result += " path=\"#{n[:children_paths]}\""
      result += " onclick=\"setCategory(this, '" + n[:id].to_s + "', '" + suff + "')\">"
      result += "<div class=\"sort-handle move-cursor\"></div>" if include_sort_handle
      #result += image_tag('categories/' + n[:symbol] + '.svg', :class => 'rounded-circle', :style => 'background-color: hsl(' + n[:color] + ');', 'height' => '30')
      result += fa_icon n[:symbol], class: cl, :style => 'background-color: hsl(' + n[:color] + '); padding: 5px;'
      result += " " + n[:name]
      result += "</li>"
      if n[:children].any?
        result += draw_tree(n[:children], suff, include_sort_handle: include_sort_handle)
      end
    end

    result += "</ul>"

    return result.html_safe
  end

  def draw_sortable_list(node, first_ul = true)
  	if first_ul
  		result = "<ul class=\"sortable-nested\">"
  	else
  		result = "<ul>"
  	end

  	node.each do |n|
  		cl = "rounded-circle"
  		cl += " category" unless n[:symbol].nil?
  		result += "<li class=\"category_#{n[:id]} py-2 px-0 sortable\" id=\"category_#{n[:id]}\">"
  		result += "<div class=\"sort-handle move-cursor\"></div>"
  		result += fa_icon n[:symbol], class: cl, :style => 'background-color: hsl(' + n[:color] + '); padding: 5px;'
      result += " " + n[:name]
      if n[:children].any?
        result += draw_sortable_list(n[:children], false)
      end
      result += "</li>"
  	end

  	result += "</ul>"

  	return result.html_safe

  end

end