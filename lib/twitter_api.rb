require "uri"
class TwitterApi
	def initialize
		@client = Twitter::REST::Client.new do |config|
		  config.consumer_key        = Rails.application.secrets.twitter_consumer_key
		  config.consumer_secret     = Rails.application.secrets.twitter_consumer_secret
		  config.access_token        = Rails.application.secrets.twitter_access_token
		  config.access_token_secret = Rails.application.secrets.twitter_access_token_secret
		end
	end

	def tweets user
		@client.user_timeline(user).reject{|t| t.retweet?}
	end

	def tweets_hash user
		tweets(user).collect { |t| {text: t.text, url: URI.extract(t.text).last} }
	end
end
