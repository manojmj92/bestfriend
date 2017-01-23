module DashboardHelper
  def unique_reaction_counts(users)
    users.map {|user| user.count}.sum
  end
end
