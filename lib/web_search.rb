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

	def self.get_page_text url, user
		redis = Redis.new
		store = redis.get(url)
		if store.blank?
			agent = Mechanize.new
			page = agent.get(url)
			text = page.search('p').collect { |p| p.text }.join("\n")
			chunks = text.scan(/(?:((?>.{1,2000}(?:(?<=[^\S\r\n])[^\S\r\n]?|(?=\r?\n)|$|[^\S\r\n]))|.{1,2000})(?:\r?\n)?|(?:\r?\n|$))/).flatten.compact.map(&:strip)
			msg = "#{chunks[0]} . . ."
			redis.set(url, {paragraphs: chunks, users: [{id: user.external_id, slice: 1}]}.to_json)
		else
			store = JSON.parse(store)
			users = store['users']
			if !users.blank?
				user = users.find{|h| h['id'] == user.external_id}
				if user['slice'].to_i < store['paragraphs'].length && !store['paragraphs'][user['slice'].to_i].blank?
					msg = "#{store['paragraphs'][user['slice'].to_i]} . . ."
					user['slice'] = user['slice'].to_i + 1
					redis.set(url, {paragraphs: store['paragraphs'], users: users}.to_json)
				else
					msg = ''
					redis.set(url, '')
				end
			end
		end
		msg
	end
end