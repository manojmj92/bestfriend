class DashboardController < ApplicationController

  def index
    if params[:since] && params[:until]
      result = ::FbAnalytics.new(current_user.oauth_token, params[:since], params[:until]).perform
      @liked_users = result[:liked_users_analytics]
      @commented_users = result[:commented_users_analytics]
      @posts_count = result[:posts_count]
    else
      @liked_users = []
      @commented_users = []
      @posts_count = 0
    end
  end

end
