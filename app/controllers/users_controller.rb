class UsersController < ApplicationController

	skip_before_action :authenticate, only: [:login, :index]

	def index
	   redirect_to dashboard_index_path if current_user
	end

	def login
    user = User.from_omniauth(env["omniauth.auth"])
    session[:user_id] = user.id
    redirect_to root_path
  end

  def signout
    session[:user_id] = nil
    redirect_to root_path
  end

end
