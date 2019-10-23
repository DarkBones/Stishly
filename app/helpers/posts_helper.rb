module PostsHelper

	def post_html(text)
		require 'redcarpet'

		markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML)
		return markdown.render(text).html_safe
	end

end
