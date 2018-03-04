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

	def fix_url url
		url.starts_with?('http') ? url : "http://#{url}"
	end

	def tweet t
		{
			text: t.full_text,
			url: fix_url(t.uris[0].display_url),
			type: t.uris[0].display_url.starts_with?('twitter.com') ? 'Twitter' : 'External'
		}
	end

	def tweets_hash user
		tws = tweets(user).collect { |twt| tweet(twt) }
		tws.select { |twt| twt[:type] == 'External' }.compact
	end
end
