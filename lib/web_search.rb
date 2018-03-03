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
			text = page.search('p').collect { |p| p.text }
			redis.set(url, {paragraphs: text.chars.each_slice(315).map(&:join), users: [{id: user.external_id, slice: 0}]}.to_json)
		end

		store = JSON.parse(redis.get(url))
		users = store['users']
		if !users.blank?
			user = users.find{|h| h['id'] == user.external_id}
			user['slice'] = user['slice'].to_i + 1
			msg = "#{store['paragraphs'][user['slice'].to_i + 1]} . . ."
		end
		redis.set(url, {paragraphs: store['paragraphs'], users: users}.to_json)
		msg
	end
end