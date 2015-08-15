# This protects Sidekiq's monitoring views in production from non-admin users
class AdminConstraint
  def matches?(request)
    return false unless request.session[:user_id]
    user = User.find request.session[:user_id]
    user && user.admin?
  end
end
