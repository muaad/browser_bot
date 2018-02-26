class Facebook
  def self.send_message user, message, type="text", items=[]
    Messenger.configure do |config|
      config.page_access_token = Rails.application.secrets.fb_access_token
    end
    
    if type == "text"
      HTTParty.post("https://graph.facebook.com/v2.6/me/messages", body: {access_token: Rails.application.secrets.fb_access_token, recipient: {id: user.external_id},  message: {text: message}}, debug_output: $stdout)
    elsif type == "buttons"
      btns = create_buttons(items, message)
      Messenger::Client.send(Messenger::Request.new(btns, user.external_id))
    elsif type == "bubbles"
      bubbles = create_bubbles(items.first(10))
      Messenger::Client.send(Messenger::Request.new(bubbles, user.external_id))
    elsif type == "quick_replies"
      quick_replies = create_quick_replies(quick_replies(items), message)
      Messenger::Client.send(Messenger::Request.new(quick_replies, user.external_id))
    elsif type == "receipt"
      send_receipt(user, items)
    end
  end

  def self.quick_replies items
    quickies = []
    items.each do |item|
      quickies << Messenger::Elements::QuickReply.new(
        content_type: item[:content_type],
        title: item[:title],
        payload: item[:payload]
      )
    end
    quickies
  end

  def self.create_quick_replies quick_replies, text=""
    Messenger::Templates::QuickReplies.new(
      text: text,
      quick_replies: quick_replies
    )
  end

  def self.buttons items
    btns = []
    items.each do |item|
      btns << Messenger::Elements::Button.new(
        type: item[:type],
        title: item[:title],
        value: item[:value]
      )
    end
    btns
  end

  def self.create_buttons btns, text=""
    # [{type: "web_url", title: "Click here", value: "http://spin.im"}, {type: "web_url", title: "Click here", value: "http://spin.im"}]
    Messenger::Templates::Buttons.new(
      text: text,
      buttons: buttons(btns)
    )
  end

  def self.create_bubbles items
    # [{title: "title", subtitle: "subtitle", item_url: "http://spin.im", image_url: "http://spin.im", buttons: [{type: "web_url", title: "Click here", value: "http://spin.im"}, {type: "web_url", title: "Click here", value: "http://spin.im"}]}, {title: "title", subtitle: "subtitle", item_url: "http://spin.im", image_url: "http://spin.im", buttons: [{type: "web_url", title: "Click here", value: "http://spin.im"}, {type: "web_url", title: "Click here", value: "http://spin.im"}]}]
    bubbles = []
    items.each do |item|
      item = item.with_indifferent_access
      bubbles << Messenger::Elements::Bubble.new(
        title: item[:title],
        subtitle: item[:subtitle],
        item_url: item[:item_url],
        image_url: item[:image_url],
        buttons: buttons(item[:buttons])
      )
    end
    Messenger::Templates::Generic.new(elements: bubbles)
  end

  def self.send_receipt user, receipt
    Messenger::Client.send(
      Messenger::Request.new(receipt, user.external_id)
    )
  end

  def self.create_receipt order, order_elements, summary, name='Order Confirmation', address=nil, adjustments=[]
    Messenger::Templates::Receipt.new(
      recipient_name: name,
      order: order,
      elements: order_elements,
      address: address,
      summary: summary,
      adjustments: adjustments
    )
  end

  def self.order order_details={}
    order_details = order_details.with_indifferent_access
    Messenger::Elements::Order.new(
      order_number: order_details[:order_number],
      currency: order_details[:currency],
      payment_method: order_details[:payment_method],
      timestamp: order_details[:timestamp],
      order_url: order_details[:order_url]
    )
  end

  def self.order_elements items
    elements = []
    items.each do |item|
      item = item.with_indifferent_access
      elements << Messenger::Elements::Item.new(
        title: item[:title],
        subtitle: item[:subtitle],
        quantity: item[:quantity],
        price: item[:price],
        currency: item[:currency],
        image_url: item[:image_url]
      )
    end
    elements
  end

  def self.summary total_cost, subtotal=nil, shipping_cost=nil, total_tax=nil
    Messenger::Elements::Summary.new(subtotal: subtotal, shipping_cost: shipping_cost, total_tax: total_tax, total_cost: total_cost)
  end

  def self.send_image user, image_url
    HTTParty.post("https://graph.facebook.com/v2.6/me/messages", body: {access_token: Rails.application.secrets.fb_access_token, recipient: {id: user.external_id},  message: {attachment: {type: "image", payload: {url: image_url}}}}, debug_output: $stdout)
  end

  def self.profile user
    HTTParty.get("https://graph.facebook.com/v2.6/#{user.external_id}?fields=first_name,last_name,gender,profile_pic&access_token=#{Rails.application.secrets.fb_access_token}")
  end

  def message_details params
    sender_id = params['entry'][0]['messaging'][0]['sender']['id']
    message = params['entry'][0]['messaging'][0]['message']['text']
    {sender_id: sender_id, message: message}
  end
end