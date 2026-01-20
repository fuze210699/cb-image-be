module Admin
  class DashboardController < BaseController
    def index
      @total_users = User.count
      @active_subscriptions = UserSubscription.where(status: 'active').count
      @total_revenue = UserPurchaseHistory.completed.sum(:amount)
      @recent_purchases = UserPurchaseHistory.recent.limit(10)
    end
  end
end
