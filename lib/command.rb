require "fb"
require "twitter_api"
class Command
	def self.news user, text
		sources = ["dailynation", "standardkenya", "citizentvkenya"]
		src = "Daily Nation"
		category = "local"
		if command_params(text)
			if command_params(text) == "tech"
				sources = ["nytimestech", "bbctech", "venturebeat", "techcrunch"]
				src = "New York Times"
				category = "technology"
			elsif command_params(text) == "sport" || command_params(text) == "sports"
				sources = ["bbcsport", "skysports"]
				src = "BBC"
				category = "sports"
			elsif command_params(text) == "international"
				sources = ["AJEnglish", "bbc", "nyt", "cnn"]
				src = "Al Jazeera"
				category = "international news"
			elsif command_params(text).downcase == "somali" || command_params(text).downcase == "somalia"
				sources = ["BBCSomali"]
				src = "BBC Somali"
				category = "Somali news"
			end
		end
		twitter = TwitterApi.new
		tweets = twitter.tweets_hash(sources).take(10)
    	Facebook.send_message(user, "Here are some of the latest #{category} stories making headlines on the web:\n\n")
  		items = []
		tweets.each do |tweet|
			btns = [{type: "postback", title: 'Read More', value: tweet[:url], subtitle: tweet[:url]}]
			items << {title: tweet[:text], buttons: btns}
		end
  		Facebook.send_message user, '', 'bubbles', items
	end

	def self.jokes user, text
		twitter = TwitterApi.new
		joke = (twitter.tweets(["best_jokes", "badjokecat"])).sample.full_text
		Facebook.send_message(user, joke, 'quick_replies', btn_items)
	end

	def self.quotes user, text
		twitter = TwitterApi.new
		quote = (twitter.tweets(["quotes4ursoul", "inspowerminds"])).sample.full_text
		Facebook.send_message(user, quote, 'quick_replies', btn_items)
	end

	def self.stats user, text
		twitter = TwitterApi.new
		stat = twitter.tweets(["optajoe"]).sample.full_text
		Facebook.send_message(user, stat, 'quick_replies', btn_items)
	end

	def self.command_params message
		p = nil
		if message.start_with?("/")
			elements = message.split("/").reject!{|e| e.blank?}
		else
			elements = message.split("/")
		end
		if elements.count == 2
			p = elements.last
		elsif elements.count > 2
			p = elements[1..-1].join('/')
		end
		p
	end

	def self.btn_items
		[
			{content_type: 'text', title: 'Search The Web', payload: '/search'}, 
			{content_type: 'text', title: 'Ask A Question', payload: '/question'}, 
			{content_type: 'text', title: 'Go To A Web Page', payload: '/url'},
			{content_type: 'text', title: 'News', payload: '/news'},
			{content_type: 'text', title: 'Jokes', payload: '/jokes'},
			{content_type: 'text', title: 'Quotes', payload: '/quotes'},
			{content_type: 'text', title: 'Soccer Stats', payload: '/stats'},
		]
	end
end