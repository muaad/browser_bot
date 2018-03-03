Rails.application.routes.draw do
  get 'pages/index'

  get 'pages/string_test'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  post '/break_strings' => 'pages#break_text'
  post '/fb' => 'messages#fb'
  get '/fb' => 'messages#fb_verify'
end
