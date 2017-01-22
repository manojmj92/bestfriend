class UsersController < ApplicationController
	
	before_action :authenticate, except: [:login, :index]
	
	def index
		redirect_to dashboard_path unless current_user.nil?
	end

	def dashboard
		unless params[:since].nil? && params[:until].nil?
		 		fetch_posts 
		 end 
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

  private

  def authenticate
  	if session[:user_id].nil?
  		redirect_to root_path
  	end
  end

  def fetch_posts
  	graph = Koala::Facebook::API.new(current_user.oauth_token)
		post_ids = graph.get_connection('me', 'posts',{
			limit: 1000,
			since: params[:since],
			until: params[:until],
      fields: ['id'] }).pluck("id")

		@post_count = post_ids.count

		@likes = Hash.new
		all_liked_users = Array.new

		@comments = Hash.new
		all_commented_users = Array.new

		# @shares = Hash.new
		# all_shared_users = Array.new

		post_ids.each do |post_id|
			liked_users = graph.get_connection(post_id,"reactions", {limit: 5000})
			commented_users = graph.get_connection(post_id,"comments", {limit: 5000})
			# shared_users = graph.get_connection(post_id,"sharedposts", {summary: true})

			all_liked_users = all_liked_users + liked_users
			all_commented_users = all_commented_users + commented_users
			# all_shared_users = all_shared_users + shared_users  
		end
		all_liked_users.each do |user|
			if @likes[user['id']].nil?
				@likes[user['id']] = { :count => 1, :name => user['name'] } 
			else
				@likes[user['id']][:count] += 1 
			end
		end
		all_commented_users.each do |user|
			if @comments[user['from']['id']].nil?
				@comments[user['from']['id']] = { :count => 1, :name => user['from']['name'] } 
			else
				@comments[user['from']['id']][:count] += 1 
			end
		end
		# all_shared_users.each do |user|
		# 	if @shares[user['id']].nil?
		# 		@shares[user['id']] = { :count => 1, :name => user['name'] } 
		# 	else
		# 		@shares[user['id']][:count] += 1 
		# 	end
		# end


		@likes = @likes.sort_by {|_key, value| -value[:count] }.to_h
		@comments = @comments.sort_by {|_key, value| -value[:count] }.to_h
		# @shares = @shares.sort_by {|_key, value| -value[:count] }
  end
end
