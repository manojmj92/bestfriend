class FbAnalytics

  attr_reader :auth_token, :start_date, :end_date
  def initialize(auth_token, start_date, end_date)
    @auth_token = auth_token
    @start_date = start_date
    @end_date = end_date
  end

  ACTIONS = {
    reaction: "reactions",
    comments: "comments"
  }

  def perform
    all_liked_users = post_ids.inject([]) do |result, post_id|
      result << users_for_post(post_id, ACTIONS[:reaction])
      result
    end
    all_commented_users = post_ids.inject([]) do |result, post_id|
      result << users_for_post(post_id, ACTIONS[:comments])
      result
    end
    all_liked_users = all_liked_users.reject { |_| _.empty? }
    all_commented_users = all_commented_users.reject { |_| _.empty?}

    final_result = Hash.new
    final_result[:liked_users_analytics] = analytics(all_liked_users)
    final_result[:commented_users_analytics] = analytics(all_commented_users)
    final_result[:posts_count] = post_ids.count
    final_result
  end

  private

  def graph
    @graph ||= Koala::Facebook::API.new(auth_token)
  end

  def post_ids
    @post_ids ||= graph.get_connection('me', 'posts',{
      limit: 1000,
      since: start_date,
      until: end_date,
      fields: ['id'] }).pluck("id")
  end

  def users_for_post(post_id, action)
    graph.get_connection(post_id, action, {limit: 5000})
  end

  def analytics(users)
    result = users.flatten.inject({}) do |res,user|
      if res[user['id']].nil?
        res[user['id']] = { :count => 1, :name => user['name'] || user['from']['name'] }
      else
        res[user['id']][:count] += 1
      end
      res
    end
    final_result = result.sort_by {|_key, value| -value[:count] }.to_h.values.inject([]) do |result, data|
      result << Analytics.new({name: data[:name], count: data[:count]})
      result
    end
    final_result
  end



end
