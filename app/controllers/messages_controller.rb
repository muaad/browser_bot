require "web_search"
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
		    quick_reply = !messaging['message']['quick_reply'].blank?
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
		      w = WebSearch.new(text)
		      logger.info ">>>>>> #{w.results}"
		      Facebook.send_message(user, 'Here are your search results:')

  	  		items = []
    			w.results.each do |opt|
    				btns = [{type: "postback", title: 'Read More', value: opt[:href]}]
    				items << {title: opt[:text], buttons: btns}
    			end
  	  		Facebook.send_message user, '', 'bubbles', items
	  	  		# items = []
	  	  		# btns = []
	  	  		# # [{type: "web_url", title: "Click here", value: "http://spin.im"}, {type: "web_url", title: "Click here", value: "http://spin.im"}]
	    			# w.results.each do |opt|
	    			# 	btns << {type: "web_url", title: 'Read More', value: opt['href']}
	    			# 	items << {title: opt['text'], subtitle: 'subtitle', buttons: btns}
	    			# end
		      # 	Facebook.send_message user, '', 'bubbles', items
		    end
		  end
		end

		render text: 'ok'
	end

	def fb_verify
		if params["hub.verify_token"] == Rails.application.secrets.fb_verify_token
			render plain: params["hub.challenge"]
		end
	end
end