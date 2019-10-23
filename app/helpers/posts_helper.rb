module PostsHelper

	def post_html(text)
		text = format_lists(text)
		text = format_paragraphs(text)
		text = format_tags(text)

		return text.html_safe
	end

private

	def format_lists(text)
		result = ""

		lists = text.split(/(^-\s(.|[\r\n])*[\r\n]{3,})/)
		lists.each do |list|
			puts "-----------------------------------"
			puts list
			if list.match(/^-\s.*/) || list.match(/^\*\s.*/)
				if list.match(/^-\s.*/)
					type = "ul"
				else
					type = "ol"
				end

				result += "<#{type}>"

				items = list.split(/[\r\n]/)
				items.each do |item|
					if item.match(/^(-|\*)\s.*/)
						item = item.gsub(/^((-|\*)|[\r\n](-|\*))\s/, '')
						item = "<li>#{item}</li>"
						result += item
					end
				end
				
				result += "</#{type}>"

			else
				result += list
			end
		end

		return result
	end
	
	def format_tags(text)
		text = text.gsub(/\^b.*\^b/){|s| '<b>' + s.gsub('^b', '') + '</b>' }
		text = text.gsub(/\^i.*\^i/){|s| '<i>' + s.gsub('^i', '') + '</i>' }
		text = text.gsub(/\^u.*\^u/){|s| '<u>' + s.gsub('^u', '') + '</u>' }
		text = text.gsub(/\^str.*\^str/){|s| '<strike>' + s.gsub('^str', '') + '</strike>' }
		return text
	end

	def format_paragraphs(text)
		ps = ""
		paragraphs = text.split(/(\A|[\n\r]{3,})[.\r\n]*/)
		paragraphs.each do |p|
			p = p.gsub(/[\r\n]{3,}/, '')
			ps += "<p>" + p + "</p>" unless p.length == 0
		end

		return ps
	end

end
