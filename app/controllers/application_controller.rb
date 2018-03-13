class ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session

  def tracker
  	render json: {success: true}
  end
end
