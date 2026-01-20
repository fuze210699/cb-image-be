class SubscriptionsController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource class: UserSubscription

  def show
    @subscription = current_user.user_subscription
  end

  def new
    @subscription = UserSubscription.new
    @promotions = Promotion.active.valid_now
  end

  def create
    @subscription = current_user.build_user_subscription(subscription_params)
    @subscription.start_date = Time.current
    
    # Calculate end date based on subscription type
    @subscription.end_date = case @subscription.subscription_type
                              when 'monthly'
                                @subscription.start_date + 1.month
                              when 'yearly'
                                @subscription.start_date + 1.year
                              end

    # Apply promotion if provided
    if params[:promotion_code].present?
      promotion = Promotion.find_by(code: params[:promotion_code])
      if promotion&.promotion_valid?
        @subscription.promotion = promotion
        @subscription.price = promotion.apply_discount(@subscription.price)
        promotion.use!
      end
    end

    if @subscription.save
      # Create purchase history
      UserPurchaseHistory.create(
        user: current_user,
        purchase_type: 'subscription',
        amount: @subscription.price,
        description: "#{@subscription.subscription_type.capitalize} subscription",
        promotion: @subscription.promotion
      )

      redirect_to subscription_path, notice: 'Subscription created successfully!'
    else
      @promotions = Promotion.active.valid_now
      render :new
    end
  end

  def cancel
    @subscription = current_user.user_subscription
    
    if @subscription.cancel!
      redirect_to subscription_path, notice: 'Subscription cancelled successfully.'
    else
      redirect_to subscription_path, alert: 'Failed to cancel subscription.'
    end
  end

  private

  def subscription_params
    params.require(:user_subscription).permit(:subscription_type, :price)
  end
end
