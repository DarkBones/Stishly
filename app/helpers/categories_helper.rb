module CategoriesHelper

	def draw_tree(node, suff="", ul_class: "", include_sort_handle: false)
    result = "<ul class=\"#{ul_class}\">"
    node.each do |n|
      cl = "rounded-circle"
      cl += " category" unless n[:symbol].nil?
      result += "<li class=\"category_" + n[:id].to_s + " clickable dropdown-item py-2 px-0\""
      result += " path=\"#{n[:children_paths]}\""
      result += " onclick=\"setCategory(this, '" + n[:id].to_s + "', '" + suff + "')\">"
      result += "<div class=\"sort-handle move-cursor\"></div>" if include_sort_handle
      result += fa_icon n[:symbol], class: cl, :style => 'background-color: ' + n[:color] + '; padding: 5px;'
      result += " " + n[:name]
      result += "</li>"
      if n[:children].any?
        result += draw_tree(n[:children], suff, include_sort_handle: include_sort_handle)
      end
    end

    result += "</ul>"

    return result.html_safe
  end

  def draw_sortable_list(node, first_ul=true)
  	if first_ul
  		result = "<ul class=\"sortable-nested unselectable\" id=\"categories_list\" unselectable=\"on\">"
  	else
  		result = "<ul class=\"unselectable\">"
  	end

  	node.each do |n|
  		cl = "rounded-circle"
  		cl += " category" unless n[:symbol].nil? || n[:symbol].length == 0
  		result += "<li class=\"category_#{n[:id]} py-2 px-0 sortable dropdown-item\" id=\"category_#{n[:id]}\""
      result += " color=\"#{n[:color]}\"" if n[:color_inherited] == false
      result += "><div>"
      result += "<span id=\"category_#{n[:id]}\" class=\"category_html\">"
  		result += "<div class=\"sort-handle move-cursor\"></div>"
  		result += fa_icon n[:symbol], class: cl, :style => 'background-color: ' + n[:color] + '; padding: 5px;'
      result += " " + n[:name]
      # delete button
      result += "<span class=\"float-right clickable category-delete-button\" onclick=\"prepareDeleteCategory('#{n[:id]}');\">"
      result += fa_icon "trash"
      result += "</span>"
      result += "</div></span>"


      # edit form
      result += "<span id=\"edit_category_#{n[:id]}\"></span>"

      if n[:children].any?
        result += draw_sortable_list(n[:children], false)
      end
      result += "</li>"
  	end

  	result += "</ul>"

  	return result.html_safe

  end

end
