class Post
	class FormatHtml

		def initialize(text)
			@text = text
		end

		def perform
			return format_html(@text).html_safe
		end

private

		def format_html(text)
			text = format_paragraphs(text)
			text = format_linebreaks(text)
			text = format_tags(text)
			text = format_links(text)
			return text
		end

		def format_links(text)
			text = text.gsub(/\[a.*,.*\]/) {
				|s|
				s = s.gsub(/\[a/, "")
				s = s.gsub(/\]/, "")
				s = s.split(", ")
				#{}"<a href=></a>"
				s = '<a href="/' + s[0].strip + '" target="new">' + s[1] + "</a>"
			}
		end

		def format_tags(text)
			text = text.gsub(/\^b.*\^b/){|s| '<b>' + s.gsub('^b', '') + '</b>' }
			text = text.gsub(/\^i.*\^i/){|s| '<i>' + s.gsub('^i', '') + '</i>' }
			text = text.gsub(/\^u.*\^u/){|s| '<u>' + s.gsub('^u', '') + '</u>' }
			text = text.gsub(/\^str.*\^str/){|s| '<strike>' + s.gsub('^str', '') + '</strike>' }
			return text
		end

		def format_linebreaks(text)
			return text.gsub(/[\r\n]+/, "<br />")
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
end