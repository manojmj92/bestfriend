class ApplicationController < ActionController::Base

  protect_from_forgery with: :exception
  helper_method :current_user
  before_action :authenticate

  private

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def authenticate
    redirect_to root_path if session[:user_id].nil?
  end

end
