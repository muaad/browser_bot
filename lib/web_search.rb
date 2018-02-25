require "mechanize"
class WebSearch
	def initialize text
		agent = Mechanize.new
		page = agent.get('http://duckduckgo.com/')
		form = page.form('x')
		form.q = text
		@page = agent.submit(form)
	end
	
	def results
		# r = @page.search('.result__snippet')
		# r.collect { |s| s.text }
		links = @page.search('a.result__a')
		r = []
		links.each do |link|
			r << {
				href: @page.links_with(text: link.text)[0].href,
				text: @page.links_with(text: link.text)[0].text
			}
		end
		r
	end
end