require "web_search"
require "wolfram_alpha"
require "fb"
require "command"
class MessagesController < ApplicationController
	def fb
		params['entry'].each do |entry|
		  page_id = entry['id']
		  entry['messaging'].each do |messaging|
		  	msg_details = Facebook.message_details(messaging)
		    sender_id = msg_details[:sender_id]
		    postback = msg_details[:postback]
		    quick_reply = msg_details[:quick_reply]
		    text = msg_details[:text]

		    if page_id == Rails.application.secrets.fb_page_id.to_s
		      logger.info ">>>>> #{text}"

		      user = User.find_or_initialize_by(external_id: sender_id, channel: 'Facebook')
		      if user.new_record?
		        profile = Facebook.profile(user)
		        name = "#{profile['first_name']} #{profile['last_name']}".encode('utf-8', 'binary', invalid: :replace, undef: :replace, replace: '')
		        user.name = name
		        user.save!
		      end

		      if postback || quick_reply
		      	handle_commands(text, user)
		      else
		      	if text.starts_with?('/')
		      		handle_commands(text, user)
		      	else
			      	step = $redis.get(user.external_id)
			      	if step.blank?
				      	search_the_web(text, user)
			      	else
			      		case step
			      		when 'Search'
					      	search_the_web(text, user)
			  		  	when 'Question'
			  		  		answer_question(text, user)
			  		  	when 'URL'
					      	go_to_url(text, user)
			      		end
			      	end
		      	end
		      end
		    end
		  end
		end
		render json: {status: 200, success: true}
	end

	def fb_verify
		if params["hub.verify_token"] == Rails.application.secrets.fb_verify_token
			render plain: params["hub.challenge"]
		end
	end

	private
		def btn_items
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

		def handle_commands text, user
			case text
			when '/back'
				msg = 'You have stopped reading the last article. Choose from the following options to proceed:'
				items = btn_items
				Facebook.send_message(user, msg, 'quick_replies', items)
			when '/search'
				$redis.set(user.external_id, 'Search')
				msg = 'Tell me what I can search for'
				Facebook.send_message(user, msg)
			when '/question'
				$redis.set(user.external_id, 'Question')
				msg = 'What is your question? I will try to find an answer for you. Tip: make it brief and understandable.'
				Facebook.send_message(user, msg)
			when '/url'
				$redis.set(user.external_id, 'URL')
				msg = 'Which website do you want to go to? Send it in the correct format. For example, google.com.'
				Facebook.send_message(user, msg)
			when '/start'
				msg = "Hi #{user.name},\n\nWelcome to Browser Bot. I will help you browse the web and find answers to your queries. Please select one of the options below to proceed:"
				items = [{content_type: 'text', title: 'Search The Web', payload: '/search'}, {content_type: 'text', title: 'Ask A Question', payload: '/question'}, {content_type: 'text', title: 'Go To A Web Page', payload: '/url'}, {content_type: 'text', title: 'About', payload: '/about'}]
				Facebook.send_message(user, msg, 'quick_replies', items)
			when '/about'
				msg = "I am a bot that will help you browse the web right from Facebook Messenger. You can do the following: \n\n- Search the web\n- Ask questions and get answers\n- Go to any web page\n\nFor more information, contact my developer at https://twitter.com/MuaadAM."
				items = btn_items
				Facebook.send_message(user, msg, 'quick_replies', items)
			when '/news'
				msg = "Select the category of news"
				items = [
									{
										content_type: 'text', title: 'International', payload: '/news/international'
									}, 
									{
										content_type: 'text', title: 'Kenya', payload: '/news/local'
									},
									{
										content_type: 'text', title: 'Sports', payload: '/news/sports'
									},
									{
										content_type: 'text', title: 'Tech', payload: '/news/tech'
									}
								]
				Facebook.send_message(user, msg, 'quick_replies', items)
			else
				if text.starts_with?('/news/')
					Command.news(user, text)
				elsif text.starts_with?('/jokes')
					Command.jokes(user, text)
				elsif text.starts_with?('/quotes')
					Command.quotes(user, text)
				elsif text.starts_with?('/stats')
					Command.stats(user, text)
				else
					read_web_page(text, user)
				end
			end
		end

		def read_web_page text, user
			msg = WebSearch.get_page_text(text, user)
			if !msg.blank?
				if !msg.starts_with?('We could not fetch')
					items = [{content_type: 'text', title: 'Read More', payload: text}, {content_type: 'text', title: 'Back', payload: '/back'}]
					Facebook.send_message(user, msg, 'quick_replies', items)
				else
					items = btn_items
					Facebook.send_message(user, msg, 'quick_replies', items)
				end
			else
				msg = 'You have finished reading the article. Choose from the following options to proceed:'
				items = btn_items
				Facebook.send_message(user, msg, 'quick_replies', items)
			end
		end

		def answer_question text, user
			duck = JSON.parse(HTTParty.get("https://api.duckduckgo.com/?q=#{text}&format=json&pretty=1").parsed_response)
			if duck['Abstract'].blank?
				msg = WolframAlpha.answer(text)
			else
				msg = duck['Abstract']
			end
			items = btn_items
			Facebook.send_message(user, msg, 'quick_replies', items)
		end

		def go_to_url text, user
    	w = WebSearch.new(text)
    	Facebook.send_message(user, 'Here are web pages that match the URL you sent. Please select the one you intend to navigate to.')
  		items = []
			w.results.each do |opt|
				btns = [{type: "postback", title: 'Read More', value: opt[:href], subtitle: opt[:href]}]
				items << {title: opt[:text], buttons: btns}
			end
  		Facebook.send_message user, '', 'bubbles', items
		end

		def search_the_web text, user
    	w = WebSearch.new(text)
    	Facebook.send_message(user, 'Here are your search results:')
  		items = []
			w.results.each do |opt|
				btns = [{type: "postback", title: 'Read More', value: opt[:href], subtitle: opt[:href]}]
				items << {title: opt[:text], buttons: btns}
			end
  		Facebook.send_message user, '', 'bubbles', items
		end
end