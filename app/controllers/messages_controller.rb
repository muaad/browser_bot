require "web_search"
require "wolfram_alpha"
require "fb"
class MessagesController < ApplicationController
	def fb
		params['entry'].each do |entry|
		  page_id = entry['id']
		  logger.info "Handing update for page #{page_id}"
		  entry['messaging'].each do |messaging|
		    sender_id = messaging['sender']['id']
		    recipient_id = messaging['recipient']['id']
		    postback = !messaging['postback'].blank?
		    quick_reply = !messaging['message'].blank? && !messaging['message']['quick_reply'].blank?
		    if !postback
		      if !messaging['message'].blank?
		        text = messaging['message']['text']
		        notification_type = "MessageReceived"
		        if !messaging['message']['attachments'].blank?
		          if messaging['message']['attachments'][0]['type'] == "image"
		            notification_type = "ImageReceived"
		            image_url = messaging['message']['attachments'][0]['payload']['url']
		          elsif messaging['message']['attachments'][0]['type'] == "location"
		            notification_type = "LocationReceived"
		            location = messaging['message']['attachments'][0]
		          end
		        end
		      end
		    else
		      text = messaging['postback']['payload']
		      notification_type = "MessageReceived"
		    end

		    if quick_reply
		      text = messaging['message']['quick_reply']['payload']
		    end

		    if page_id == Rails.application.secrets.fb_page_id.to_s
		      logger.info ">>>>> #{text}"

		      user = User.find_or_initialize_by(external_id: sender_id, channel: 'Facebook')
		      if user.new_record?
		        profile = Facebook.profile(user)
		        name = "#{profile['first_name']} #{profile['last_name']}".encode('utf-8', 'binary', invalid: :replace, undef: :replace, replace: '')
		        user.name = name
		        user.save!
		      end

		      redis = Redis.new
		      if postback || quick_reply
		      	case text
		      	when '/back'
		      		msg = 'You have stopped reading the last article. Choose from the following options to proceed:'
		      		items = [{content_type: 'text', title: 'Search The Web', payload: '/search'}, {content_type: 'text', title: 'Ask A Question', payload: '/question'}, {content_type: 'text', title: 'Go To A Web Page', payload: '/url'}]
		      		Facebook.send_message(user, msg, 'quick_replies', items)
		      	when '/search'
		      		redis.set(user.external_id, 'Search')
		      		msg = 'Tell me what I can search for'
		      		Facebook.send_message(user, msg)
		      	when '/question'
		      		redis.set(user.external_id, 'Question')
		      		msg = 'What is your question? I will try to find an answer for you. Tip: make it brief and understandable.'
		      		Facebook.send_message(user, msg)
		      	when '/url'
		      		redis.set(user.external_id, 'URL')
		      		msg = 'Which website do you want to go to? Send it in the correct format. For example, google.com.'
		      		Facebook.send_message(user, msg)
		      	else
		      		msg = WebSearch.get_page_text(text, user)
		      		if !msg.blank?
		      			items = [{content_type: 'text', title: 'Read More', payload: text}, {content_type: 'text', title: 'Back', payload: '/back'}]
		      			Facebook.send_message(user, msg, 'quick_replies', items)
		      		else
		      			msg = 'You have finished reading the article. Choose from the following options to proceed:'
		      			items = [{content_type: 'text', title: 'Search The Web', payload: '/search'}, {content_type: 'text', title: 'Ask A Question', payload: '/question'}, {content_type: 'text', title: 'Go To A Web Page', payload: '/url'}]
		      			Facebook.send_message(user, msg, 'quick_replies', items)
		      		end
		      	end
		      else
		      	step = redis.get(user.external_id)
		      	if step.blank?
			      	w = WebSearch.new(text)
			      	Facebook.send_message(user, 'Here are your search results:')
	  		  		items = []
	  	  			w.results.each do |opt|
	  	  				btns = [{type: "postback", title: 'Read More', value: opt[:href]}]
	  	  				items << {title: opt[:text], buttons: btns}
	  	  			end
	  		  		Facebook.send_message user, '', 'bubbles', items
		      	else
		      		case step
		      		when 'Search'
				      	w = WebSearch.new(text)
				      	Facebook.send_message(user, 'Here are your search results:')
		  		  		items = []
		  	  			w.results.each do |opt|
		  	  				btns = [{type: "postback", title: 'Read More', value: opt[:href]}]
		  	  				items << {title: opt[:text], buttons: btns}
		  	  			end
		  		  		Facebook.send_message user, '', 'bubbles', items
		  		  	when 'Question'
		  		  		duck = JSON.parse(HTTParty.get("https://api.duckduckgo.com/?q=#{text}&format=json&pretty=1").parsed_response)
		  		  		if duck['Abstract'].blank?
		  		  			msg = WolframAlpha.answer(text)
		  		  		else
		  		  			msg = duck['Abstract']
		  		  		end
		  		  		items = [{content_type: 'text', title: 'Search The Web', payload: '/search'}, {content_type: 'text', title: 'Ask A Question', payload: '/question'}, {content_type: 'text', title: 'Go To A Web Page', payload: '/url'}]
		  		  		Facebook.send_message(user, msg, 'quick_replies', items)
		  		  	when 'URL'
				      	w = WebSearch.new(text)
				      	Facebook.send_message(user, 'Here are web pages that match the URL you sent. Please select the one you intend to navigate to.')
		  		  		items = []
		  	  			w.results.each do |opt|
		  	  				btns = [{type: "postback", title: 'Read More', value: opt[:href]}]
		  	  				items << {title: opt[:text], buttons: btns}
		  	  			end
		  		  		Facebook.send_message user, '', 'bubbles', items
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
end