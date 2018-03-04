require "fb"
require "twitter_api"
class Command
	def self.news user, text
		source = "dailynation"
		src = "Daily Nation"
		category = "local"
		if command_params(text)
			if command_params(text) == "tech"
				source = "nytimestech"
				src = "New York Times"
				category = "technology"
			elsif command_params(text) == "sport" || command_params(text) == "sports"
				source = "bbcsport"
				src = "BBC"
				category = "sports"
			elsif command_params(text) == "international"
				source = "AJEnglish"
				src = "Al Jazeera"
				category = "international news"
			elsif command_params(text).downcase == "somali" || command_params(text).downcase == "somalia"
				source = "BBCSomali"
				src = "BBC Somali"
				category = "Somali news"
			end
		end
		twitter = TwitterApi.new
		tweets = twitter.tweets_hash(source).take(10)
    	Facebook.send_message(user, "Here are the 5 latest #{category} stories making headlines on the #{src}:\n\n")
  		items = []
		tweets.each do |tweet|
			btns = [{type: "postback", title: 'Read More', value: tweet[:url], subtitle: tweet[:url]}]
			items << {title: tweet[:text], buttons: btns}
		end
  		Facebook.send_message user, '', 'bubbles', items
	end

	def self.jokes user, text
		twitter = TwitterApi.new
		joke = (twitter.tweets("best_jokes") + twitter.tweets("badjokecat")).sample.text
		Facebook.send_message(user, joke)
	end

	def self.quotes user, text
		twitter = TwitterApi.new
		quote = (twitter.tweets("quotes4ursoul") + twitter.tweets("inspowerminds")).sample.text
		Facebook.send_message(user, quote)
	end

	def self.stats user, text
		twitter = TwitterApi.new
		stat = twitter.tweets("optajoe").sample.text
		Facebook.send_message(user, stat)
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
end