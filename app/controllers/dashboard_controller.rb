class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    @user = current_user
    @subscription = current_user.user_subscription
    @purchase_history = current_user.user_purchase_histories.recent.limit(10)
  end

  def profile
    @user = current_user
  end

  def update_profile
    @user = current_user
    
    if @user.update(user_params)
      redirect_to profile_dashboard_path, notice: 'Profile updated successfully.'
    else
      render :profile
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation, :current_password)
  end
end
